
**Azure Storage를 이용해 공유 폴더를 생성한 후 Cloud Shell에서 마운트하여 Bash 스크립트를 실행**

STORAGE_ACCOUNT_NAME=akscloudshellstorage
FILE_SHARE_NAME=aks-quickshell-share

echo "🔹 스토리지 계정 이름: $STORAGE_ACCOUNT_NAME"
echo "🔹 공유 폴더 이름: $FILE_SHARE_NAME"


### **🔹 공유 폴더 생성**  
```bash
az storage share create --name $FILE_SHARE_NAME --account-name $STORAGE_ACCOUNT_NAME --enable-files-aadds true
```


### **🔹 공유 폴더에 Bash 스크립트 업로드**  
```bash
az storage file upload-batch \
    --source docs \
    --destination $FILE_SHARE_NAME \
    --account-name $STORAGE_ACCOUNT_NAME \
    --pattern "*.sh"

```

### **🔹 공유 폴더 내용 확인**  
```bash
az storage file list \
    --share-name $FILE_SHARE_NAME \
    --account-name $STORAGE_ACCOUNT_NAME \
    --output table
```

Name                    Content Length    Type    Last Modified
----------------------  ----------------  ------  -------------------------
aks_archi_checklist.sh  2848              file    2025-02-26T11:52:58+00:00
aks_archi_env.sh        191               file    2025-02-26T11:52:58+00:00
aks_checklist.sh        3882              file    2025-02-26T11:52:58+00:00
env.sh                  184               file    2025-02-26T11:52:58+00:00