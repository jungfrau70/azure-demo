import json
import time
import dash
import networkx as nx
import plotly.graph_objects as go
from dash import dcc, html
from azure.identity import DefaultAzureCredential
from azure.mgmt.compute import ComputeManagementClient
from azure.mgmt.network import NetworkManagementClient
from azure.mgmt.storage import StorageManagementClient

# 🔹 Azure 인증 설정
credential = DefaultAzureCredential()
subscription_id = "YOUR_SUBSCRIPTION_ID"

# 🔹 Azure 클라이언트
compute_client = ComputeManagementClient(credential, subscription_id)
network_client = NetworkManagementClient(credential, subscription_id)
storage_client = StorageManagementClient(credential, subscription_id)

# 🔹 Terraform tfstate 파일 읽기
with open("terraform.tfstate", "r") as file:
    tfstate = json.load(file)

resources = tfstate["resources"]

# 🔹 리소스 데이터
nodes = []
edges = []
statuses = {}

# 🔹 Azure 상태 조회 함수
def get_vm_status(vm_name):
    try:
        vm = compute_client.virtual_machines.instance_view("myRG", vm_name)
        status = vm.statuses[-1].code
        return "🟢 Running" if "running" in status else "🔴 Stopped"
    except:
        return "⚠️ Unknown"

def get_storage_status(storage_name):
    try:
        storage = storage_client.storage_accounts.get_properties("myRG", storage_name)
        return "🟢 Available" if storage.provisioning_state == "Succeeded" else "🔴 Error"
    except:
        return "⚠️ Unknown"

# 🔹 Terraform 리소스 분석
for res in resources:
    res_type = res["type"]
    res_name = res["instances"][0]["attributes"]["name"]

    if res_type == "azurerm_virtual_machine":
        nodes.append(res_name)
        statuses[res_name] = get_vm_status(res_name)
    elif res_type == "azurerm_storage_account":
        nodes.append(res_name)
        statuses[res_name] = get_storage_status(res_name)
    elif res_type == "azurerm_virtual_network":
        nodes.append(res_name)
    elif res_type == "azurerm_subnet":
        nodes.append(res_name)

    if "depends_on" in res["instances"][0]["attributes"]:
        for dependency in res["instances"][0]["attributes"]["depends_on"]:
            edges.append((dependency.split(".")[-1], res_name))

# 🔹 NetworkX 그래프 생성
G = nx.Graph()
for node in nodes:
    G.add_node(node, status=statuses.get(node, "🟡 Unknown"))

for edge in edges:
    G.add_edge(edge[0], edge[1])

# 🔹 Plotly로 그래프 변환
pos = nx.spring_layout(G)

node_trace = go.Scatter(
    x=[pos[n][0] for n in G.nodes],
    y=[pos[n][1] for n in G.nodes],
    text=[f"{n} ({G.nodes[n]['status']})" for n in G.nodes],
    mode="markers+text",
    marker=dict(
        size=20,
        color=[
            "green" if "🟢" in G.nodes[n]["status"]
            else "red" if "🔴" in G.nodes[n]["status"]
            else "orange"
            for n in G.nodes
        ],
    ),
)

edge_trace = go.Scatter(
    x=[pos[e[0]][0] for e in G.edges] + [pos[e[1]][0] for e in G.edges],
    y=[pos[e[0]][1] for e in G.edges] + [pos[e[1]][1] for e in G.edges],
    line=dict(width=1, color="gray"),
    mode="lines",
)

# 🔹 Dash 대시보드 실행
app = dash.Dash(__name__)

app.layout = html.Div([
    html.H1("Azure Resource Monitoring"),
    dcc.Graph(figure=go.Figure(data=[edge_trace, node_trace])),
])

if __name__ == "__main__":
    app.run_server(debug=True)
