#!/usr/bin/env python3
import subprocess
import json
import os
import sys

# 1. 確保臨時憑證與環境變數在線
try:
    # 執行 aws configure export-credentials 並拿到憑證環境變數
    cred_proc = subprocess.run(
        ["aws", "configure", "export-credentials", "--profile", "default", "--format", "env"],
        capture_output=True, text=True, check=True
    )
    for line in cred_proc.stdout.splitlines():
        if line.startswith("export "):
            key_value = line.replace("export ", "").replace('"', '').split("=")
            if len(key_value) == 2:
                os.environ[key_value[0]] = key_value[1]
    os.environ["AWS_DEFAULT_REGION"] = "ap-northeast-1"
except Exception:
    print(" 無法獲取 AWS 憑證，請確認您的 AWS SSO 登入狀態。")
    sys.exit(1)

# 2. 引入 boto3 (必須在環境變數設定完後引入)
import boto3

# 3. 執行 k8sgpt 抓取原始錯誤
try:
    k8sgpt_proc = subprocess.run(
        ["k8sgpt", "analyze", "--namespace", "default"],
        capture_output=True, text=True
    )
    raw_lines = k8sgpt_proc.stdout.splitlines()
    error_msg = ""
    for i, line in enumerate(raw_lines):
        if "Error:" in line:
            error_msg = line.split("Error:")[1].strip()
            break
            
    if not error_msg:
        print(" 目前叢集運作正常，沒有發現顯著的 Pod 錯誤！")
        sys.exit(0)
except Exception as e:
    print(f" 執行 k8sgpt 失敗: {e}")
    sys.exit(1)

# 4. 建立包含你那三條鋼鐵紀律的完美提示詞
PROMPT = f"""你是一個精通 Kubernetes 的高級運維專家。請分析以下錯誤並提供解決方案。
請嚴格遵守以下三條規則：
1. 必須使用「繁體中文（台灣）」進行整體白話文分析與解答。
2. 內容必須精簡扼要，整體回答（不含代碼塊）嚴格限制在 300 字以內。
3. 所有的關鍵技術專有名詞、Kubernetes 命令、YAML 配置、JSON 檔案或錯誤代碼，請保持其原本的英文，絕對不要翻譯成中文。

錯誤內容如下：
{error_msg}"""

# 5. 用 Python 完美處理中文字，直接戳東京區的 Nova Lite
try:
    client = boto3.client("bedrock-runtime", region_name="ap-northeast-1")
    
    body_data = {
        "messages": [
            {
                "role": "user",
                "content": [{"text": PROMPT}]
            }
        ]
    }
    
    response = client.invoke_model(
        modelId="amazon.nova-lite-v1:0",
        body=json.dumps(body_data, ensure_ascii=False).encode('utf-8')
    )
    
    response_body = json.loads(response["body"].read().decode('utf-8'))
    print(response_body["output"]["message"]["content"][0]["text"])

except Exception as e:
    print(f" 呼叫 Bedrock 失敗: {e}")
