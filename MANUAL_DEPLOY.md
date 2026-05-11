Use this instruction when "Deploy to Render" button will not work.

1. Login on Render
2. + New Web Service

== Repository ==

3. Select "Enter into Public Git Repository", insert link https://github.com/api29200/n8n_v2.8.3-render-python, Connect
4. Keep default setting, Deploy Web Service. When deploy starts interrup it "Cancel deploy"
5. Copy your URL (on header, under the Service ID and github repository) e.g. https://n8n-v2-8-3-render-python.onrender.com

== Disk ==

6. Disk, AddDisk, enter Mount path /home/node/.n8n
7. Select Size, eg 1GB, AddDisk

== Environment Variables ==

8. Insert Your URL in the last variable and copy all variables

EXECUTIONS_DATA_SAVE_MANUAL_EXECUTIONS=false
EXECUTIONS_DATA_SAVE_ON_ERROR=all
EXECUTIONS_DATA_SAVE_ON_PROGRESS=false
EXECUTIONS_DATA_SAVE_ON_SUCCESS=none
N8N_BLOCK_ENV_ACCESS_IN_NODE=false
N8N_BLOCK_JS_LIB_IMPORT=false
N8N_ENCRYPTION_KEY=a8f9c2d7e1b504399e6a7d8c2f10b3e4a5d6c7b890123456789abcdef0123456
N8N_HOST=0.0.0.0
N8N_NODES_CODE_CAN_REQUIRE_MODULES_BUILTIN=fs,path,child_process,os,util
N8N_NODES_CODE_CAN_REQUIRE_MODULES_EXTERNAL=*
N8N_PORT=5678
N8N_PROTOCOL=https
N8N_PROXY_HOPS=1
N8N_RUNNERS_EXTERNAL_ALLOW=*
N8N_RUNNERS_MODE=internal
N8N_RUNNERS_STDLIB_ALLOW=*
N8N_RUNNERS_TEMP_DIRECTORY=/tmp/n8n_runner
WEBHOOK_URL=https://n8n-v2-8-3-render-python.onrender.com


9. Go to Environment
10. +Add variable / import from .env
11. Paste variables copied previously
12. Deploy and wait ca 4-6mins untill you see in events:
==> Your service is live 🎉
==> 
==> ///////////////////////////////////////////////////////////
==> 
==> Available at your primary URL https://n8n-v2-8-3-render-python.onrender.com
==> 
==> ///////////////////////////////////////////////////////////
