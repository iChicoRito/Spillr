# Spillr

A Flutter party-card app with offline AI question generation for Android.

## Android Offline Gemma Model

AI question generation uses `flutter_gemma` with Gemma 3 270M Q8. The Android
build expects the model file at:

```text
android/app/src/main/assets/models/gemma3-270m-it-q8.task
```

Download the official model file from:

```text
https://huggingface.co/litert-community/gemma-3-270m-it/resolve/main/gemma3-270m-it-q8.task
```

The Hugging Face repository is gated. Sign in, accept the Gemma license/contact
information requirement, then download with an access token:

```powershell
$env:HF_TOKEN = "hf_your_token_here"
$url = "https://huggingface.co/litert-community/gemma-3-270m-it/resolve/main/gemma3-270m-it-q8.task?download=true"
$out = "android/app/src/main/assets/models/gemma3-270m-it-q8.task"
Invoke-WebRequest -Uri $url -OutFile $out -Headers @{ Authorization = "Bearer $env:HF_TOKEN" }
```

After adding or replacing the model file, rebuild the Android app so Gradle
packages the native asset. Do not also place this model under `assets/models/`
unless Flutter asset loading is intentionally being tested, because that would
bundle a second copy of the same large file.
