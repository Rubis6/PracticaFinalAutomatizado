#!/bin/bash

APP_NAME="miapp"
REPO_DIR="$HOME/PracticaFinalAutomatizado"
SRC_DIR="$REPO_DIR/src"
BUILD_DIR="$REPO_DIR/build"
TOMCAT_WEBAPPS="/opt/tomcat/webapps"
SERVLET_JAR="/opt/tomcat/lib/jakarta.servlet-api.jar"

echo "===== INICIO DEL DESPLIEGUE ====="

cd "$REPO_DIR" || exit 1

echo "Actualizando repositorio..."
git pull origin main

echo "Limpiando build anterior..."
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR/WEB-INF/classes"

echo "Compilando servlet..."
javac -cp "$SERVLET_JAR" -d "$BUILD_DIR/WEB-INF/classes" \
"$SRC_DIR/hola/HolaServlet.java" || exit 1

echo "Creando web.xml..."
cat > "$BUILD_DIR/WEB-INF/web.xml" <<EOL
<web-app xmlns="https://jakarta.ee/xml/ns/jakartaee" version="5.0">
    <servlet>
        <servlet-name>HolaServlet</servlet-name>
        <servlet-class>hola.HolaServlet</servlet-class>
    </servlet>
    <servlet-mapping>
        <servlet-name>HolaServlet</servlet-name>
        <url-pattern>/</url-pattern>
    </servlet-mapping>
</web-app>
EOL

echo "Creando WAR..."
cd "$BUILD_DIR"
jar -cvf "$APP_NAME.war" * > /dev/null

echo "Copiando WAR..."
sudo cp "$APP_NAME.war" "$TOMCAT_WEBAPPS/"

echo "Reiniciando Tomcat..."
sudo systemctl restart tomcat

echo "Esperando despliegue..."
sleep 8

echo "Comprobando aplicación..."
curl -I http://localhost:8080/$APP_NAME/

echo "===== FIN ====="

