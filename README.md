# ⚡️ Startup Power

## 🇺🇸 English

**Startup Power** is a macOS application built with **SwiftUI** that allows you to configure your MacBook’s **automatic startup behavior**.  

It directly modifies **NVRAM variables** (`BootPreference` for Apple Silicon, `AutoBoot` for Intel) to control these options.  
The app automatically adapts its behavior depending on your Mac type.  

---

### 💻 Features by architecture

#### Mac with Apple Silicon (ARM)  
- Automatic startup when opening the lid.  
- Automatic startup when plugging in the power cable.  

#### Intel Mac  
- Only the automatic startup when opening the lid is configurable.  

---

### 🙏 Credits
Inspired by **Guillaume Gete**’s script:  
👉 [macOS Lid and Plug Power Settings](https://github.com/guillaumegete/macos_lid_and_plug_powersettings)  

---

### ⚙️ Requirements
- macOS **11 (Big Sur)** or later.  
- A **MacBook** (iMac and Mac mini are not supported).  
- **Administrator rights required** (macOS will prompt for your password).  
- ⚠️ **Note: this application is not signed by Apple.**  

From Finder :

You will need to launch it via **Right click → Open** and confirm manually in **Security Preferences**.  

From Terminal :
```
codesign --force --deep --sign - /path/to/yourApp.app
xattr -d com.apple.quarantine /path/to/yourApp.app
```

From Sentinel (drag and drop) :

Simply drag your app into the Sentinel window

---

### ⚠️ Disclaimer
⚡️ Use this application **at your own risk**.  
Incorrect **NVRAM modifications** may affect your system’s behavior.  
Always make sure you are using a **supported MacBook** before applying changes.  

---



## 🇫🇷 Français

**Startup Power** est une application macOS développée en **SwiftUI** permettant de configurer le comportement de **démarrage automatique d’un MacBook**.  

Elle agit directement sur les variables **NVRAM** (`BootPreference` pour Apple Silicon, `AutoBoot` pour Intel) afin de contrôler ces options.  
L’application adapte dynamiquement son comportement selon le type de Mac détecté.  

---

### 💻 Fonctionnalités selon l’architecture

#### Mac avec Apple Silicon (ARM)  
- Démarrage automatique à l’ouverture du capot.  
- Démarrage automatique lors du branchement du câble d’alimentation.  

#### Mac Intel  
- Seul le démarrage automatique à l’ouverture du capot est configurable.  

---

### 🙏 Crédit
Inspiré du script de **Guillaume Gete** :  
👉 [macOS Lid and Plug Power Settings](https://github.com/guillaumegete/macos_lid_and_plug_powersettings)  

---

### ⚙️ Prérequis
- macOS **11 (Big Sur)** ou version ultérieure.  
- Un **MacBook** (iMac et Mac mini non concernés).  
- **Droits administrateur requis** (macOS demandera votre mot de passe).  
- ⚠️ **Attention : l’application n’est pas signée par Apple.**  
  Vous devrez l’ouvrir via **clic droit → Ouvrir** et confirmer manuellement dans les **Préférences Sécurité**.  

---

### ⚠️ Avertissement
⚡️ L’utilisation de cette application se fait **à vos risques et périls**.  
Une mauvaise modification de la **NVRAM** peut impacter le comportement de votre système.  
Assurez-vous toujours d’utiliser un **MacBook compatible** avant d’appliquer des changements.  

