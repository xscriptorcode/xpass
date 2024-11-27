# **Xpass**

¿Te da pereza escribir tus contraseñas en un bloc y tampoco confías en las notas de tu móvil? Gestiona y protege tus contraseñas con **Xpass**, una aplicación móvil completa que utiliza criptografía avanzada para almacenarlas de forma segura.

---

## **Funciones**

### **1. Gestión de Contraseñas**
- **Agregar, Editar, Eliminar y Copiar Contraseñas**: Administra tus contraseñas de manera sencilla para diferentes plataformas y servicios.
- **Cifrado Avanzado**: Cada contraseña se cifra de manera segura antes de almacenarse.
- **Generador de Contraseñas Seguras**: Genera contraseñas aleatorias y robustas para garantizar la seguridad de tus cuentas.

### **2. Uso de Criptografía xKyber**
- **Cifrado y Descifrado Seguro**: Los datos sensibles, como contraseñas y sesiones de usuario, están protegidos con claves generadas mediante xKyber, proporcionando un nivel de seguridad superior.
- **Claves Compartidas**: Se utiliza xKyber para generar claves compartidas entre las sesiones del usuario, asegurando que los datos se mantengan seguros incluso en entornos no confiables.

### **3. Importar y Exportar Contraseñas**
- **Exportar Contraseñas**:
  - Exporta tus contraseñas cifradas a un archivo protegido por contraseña.
  - Selecciona un directorio para guardar tus contraseñas cifradas.
- **Importar Contraseñas**:
  - Restaura tus contraseñas desde un archivo cifrado usando la contraseña que utilizaste para exportarlas.
  - Compatible con múltiples dispositivos y sesiones de usuario.
- **Cifrado con Contraseña**: Se añade una capa adicional de seguridad al cifrar los datos exportados con una contraseña proporcionada por el usuario.

### **4. Gestión del Perfil del Usuario**
- **Alias Personalizado**: Configura y edita un alias para personalizar tu experiencia en la aplicación.
- **Foto de Perfil**: Subir y cambiar tu foto de perfil fácilmente desde la galería (esta función está pensada para la implementación de múltiples perfiles en el futuro, por si el usuario desea añadir uno para cada tipo de cuenta que tenga, etc.).
- **Datos Cifrados**: Toda la información del perfil se guarda de forma segura en archivos cifrados.

### **5. Seguridad Avanzada**
- **Cifrado AES-256 y xKyber**: Combina algoritmos tradicionales con criptografía post-cuántica para una doble capa de seguridad.
- **Gestión Segura de Sesiones**: Las sesiones de usuario se administran utilizando claves generadas dinámicamente.
- **Recuperación Segura**: Permite restaurar datos importando archivos cifrados.

### **6. Personalización y Configuración**
- **Modo Oscuro**: Alterna entre los modos claro y oscuro según tu preferencia.
- **Cambio de Contraseña**: Modifica tu contraseña principal directamente desde la configuración.
- **Exportación de Sesión**: Exporta los datos de sesión de forma segura para respaldo o migración.

---

## **Tecnologías Utilizadas**
- **Framework**: Flutter
- **Lenguaje de Programación**: Dart
- **Base de Datos**: SQLite para almacenamiento local
- **Criptografía**:
  - **xKyber**: Algoritmo de cifrado basado en Kyber, cifrado post-cuántico, para la generación de claves seguras.
  - **AES-256**: Estándar de cifrado avanzado para proteger datos sensibles.
  - **SHA-256**: Derivación de claves desde contraseñas proporcionadas por el usuario.
- **Gestión de Archivos**: Manejo de archivos locales para exportación, importación y almacenamiento seguro.

---

## **Instalación**
1. **Clonar el Repositorio**:
   ```bash
   git clone https://github.com/xscriptorcode/xpass.git
   cd xpass
   ```

2. **Instalar Dependencias**:
   ```bash
   flutter pub get
   ```

3. **Ejecutar la Aplicación**:
   ```bash
   flutter run
   ```

---

## **Cómo Usar**

### **Configuración Inicial**
1. Regístrate en la aplicación con un código único y una contraseña segura.
2. Configura tu alias y sube tu foto de perfil para personalizar tu cuenta.

### **Gestión de Contraseñas**
1. **Agregar Contraseñas**:
   - Desde la lista de contraseñas, presiona el botón **+** y selecciona "Nueva Contraseña".
   - Completa los campos y guarda.
2. **Exportar Contraseñas**:
   - Desde el menú, selecciona "Exportar Contraseñas".
   - Define una contraseña para cifrar el archivo y elige un directorio de exportación.
3. **Importar Contraseñas**:
   - Desde el menú, selecciona "Importar Contraseñas".
   - Selecciona el archivo exportado, introduce la contraseña y restaura las contraseñas.

### **Configuración del Usuario**
1. Edita tu alias o sube una nueva foto desde la sección de configuración.
2. Cambia la contraseña de la aplicación desde la misma sección.

---

## **Contribuciones**
Contribuciones son bienvenidas. Si encuentras un error o tienes sugerencias, por favor abre un issue o envía un pull request.

---

## **Licencia**
Este proyecto está bajo la Licencia MIT. Consulta el archivo [LICENSE](LICENSE) para más detalles.

---
