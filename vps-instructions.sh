#!/bin/bash
# تعليمات تشغيل CAA Chat على VPS
# ------------------------------

# الخطوة 1: تثبيت Docker إذا لم يكن مثبتًا بالفعل
install_docker() {
  echo "تثبيت Docker..."
  curl -fsSL https://get.docker.com | sh
  sudo systemctl enable docker
  sudo systemctl start docker
  sudo usermod -aG docker $USER
  echo "تم تثبيت Docker بنجاح!"
}

# الخطوة 2: تثبيت Docker Compose إذا لم يكن مثبتًا بالفعل
install_docker_compose() {
  echo "تثبيت Docker Compose..."
  sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
  echo "تم تثبيت Docker Compose بنجاح!"
}

# الخطوة 3: إنشاء المجلد وتنزيل الملفات اللازمة
setup_project() {
  echo "إنشاء مجلد المشروع وتنزيل الملفات..."
  mkdir -p ~/open-webui
  cd ~/open-webui
  
  # تنزيل ملفات Docker
  echo "تنزيل ملف Dockerfile..."
  curl -O https://raw.githubusercontent.com/open-webui/open-webui/main/Dockerfile
  
  echo "تنزيل ملف docker-compose.yaml..."
  curl -O https://raw.githubusercontent.com/open-webui/open-webui/main/docker-compose.yaml
  
  echo "تم تنزيل الملفات بنجاح!"
}

# الخطوة 4: تشغيل المشروع باستخدام Docker Compose
run_project() {
  echo "تشغيل المشروع باستخدام Docker Compose..."
  cd ~/open-webui
  docker-compose up -d
  echo "تم تشغيل المشروع بنجاح! يمكنك الوصول إليه من خلال العنوان http://YOUR_VPS_IP:3000"
}

# الطريقة البديلة: استخدام الصورة الجاهزة
run_with_prebuild_image() {
  echo "تشغيل المشروع باستخدام الصورة الجاهزة..."
  docker run -d -p 3000:8080 -v ollama:/root/.ollama -v open-webui:/app/backend/data --name open-webui --restart always ghcr.io/open-webui/open-webui:ollama
  echo "تم تشغيل المشروع بنجاح! يمكنك الوصول إليه من خلال العنوان http://YOUR_VPS_IP:3000"
}

echo "==================================================="
echo "  تعليمات تشغيل CAA Chat على VPS  "
echo "==================================================="
echo "للتثبيت السريع، قم بتنفيذ الأوامر التالية على VPS الخاص بك:"
echo ""
echo "# تثبيت Docker (إذا لم يكن مثبتًا بالفعل)"
echo "curl -fsSL https://get.docker.com | sh"
echo ""
echo "# تشغيل CAA Chat مع Ollama مضمناً (أسهل طريقة)"
echo "docker run -d -p 3000:8080 -v ollama:/root/.ollama -v open-webui:/app/backend/data --name open-webui --restart always ghcr.io/open-webui/open-webui:ollama"
echo ""
echo "# بعد التثبيت، يمكنك الوصول إلى المشروع من خلال المتصفح على العنوان:"
echo "http://YOUR_VPS_IP:3000"
echo ""
echo "==================================================="
echo "للتحديث في المستقبل، استخدم الأمر التالي:"
echo "docker pull ghcr.io/open-webui/open-webui:ollama"
echo "docker stop open-webui"
echo "docker rm open-webui"
echo "docker run -d -p 3000:8080 -v ollama:/root/.ollama -v open-webui:/app/backend/data --name open-webui --restart always ghcr.io/open-webui/open-webui:ollama"
echo "===================================================" 