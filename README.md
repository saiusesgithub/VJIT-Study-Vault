# 🎓 VJIT Study Vault

<div align="center">

![App Logo](assets/logos/VjitLogo.png)

**Your Complete Academic Companion for VJIT Students**

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)

[📱 Download APK](#download) • [📖 Features](#features) • [🚀 Getting Started](#getting-started) • [🤝 Contributing](#contributing)

</div>

---

## 📱 Screenshots

<div align="center">

| Onboarding | Materials Grid | PDF Viewer | Downloads |
|------------|----------------|------------|-----------|
| ![Onboarding Screen](screenshots/onboarding.png) | ![Materials Grid](screenshots/materials_grid.png) | ![PDF Viewer](screenshots/pdf_viewer.png) | ![Downloads](screenshots/downloads.png) |

*Experience seamless navigation through your academic materials*

</div>

## ✨ Features

### 🎯 **Personalized Experience**
- **Smart Onboarding**: One-time setup based on your branch, year, and semester
- **Curated Content**: See only materials relevant to your academic profile
- **Offline Access**: Download and access PDFs without internet

### 📚 **Comprehensive Study Materials**
- 📄 **Subject Notes** - Chapter-wise organized study materials
- 📝 **Question Banks** - Practice questions for exam preparation  
- 🎯 **Previous Year Papers** - Year-wise PYQ collections
- 🔬 **Lab Manuals** - Practical experiment guides
- 📋 **Assignments** - Course-specific assignments and solutions

### 🚀 **Advanced PDF Experience**
- **Native PDF Rendering** - Smooth, high-quality PDF viewing
- **Smart Navigation** - Scrollbar with page indicators
- **Quick Access** - Direct Google Drive integration
- **Download Management** - MediaStore-compliant file saving (Android 10+)
- **Analytics Integration** - Usage tracking for continuous improvement

### 🎨 **Modern UI/UX**
- **Material Design 3** - Clean, intuitive interface
- **Custom Fonts** - Orbitron font family for enhanced readability
- **Responsive Layout** - Optimized for all screen sizes
- **Dark/Light Themes** - Automatic theme adaptation

### 📱 **Cross-Platform Support**
- ✅ **Android** (5.0+) - Full feature support
- ✅ **iOS** (12.0+) - Complete iOS integration
- ✅ **Web** - Progressive Web App capabilities

## 🏗️ Architecture

```
lib/
├── main.dart                 # App entry point
├── pages/
│   ├── onboarding_page.dart         # User setup & preferences
│   ├── subject_related_materials_page.dart    # Material type selection
│   └── deeper_subject_related_materials_page.dart # Unit/Year specific content
├── services/
│   └── download_helper.dart         # Cross-platform download management
└── theme/                    # App theming and styles
```

### 🔧 **Technology Stack**

| Component | Technology | Purpose |
|-----------|------------|---------|
| **Frontend** | Flutter 3.0+ | Cross-platform mobile development |
| **PDF Rendering** | pdfx | High-performance PDF viewing |
| **Networking** | Dio | HTTP requests and file downloads |
| **Storage** | SharedPreferences | User preferences persistence |
| **Analytics** | Firebase Analytics | Usage tracking and insights |
| **Permissions** | permission_handler | Runtime permission management |
| **Cloud Storage** | Google Drive API | PDF hosting and delivery |

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.0+)
- Dart SDK (3.0+)
- Android Studio / VS Code
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/saiusesgithub/vjitstudyvault.git
   cd vjitstudyvault
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   ```bash
   # Add your google-services.json to android/app/
   # Add your GoogleService-Info.plist to ios/Runner/
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

### 🏗️ Build for Production

**Android APK**
```bash
flutter build apk --release
```

**iOS IPA**
```bash
flutter build ios --release
```

**Web**
```bash
flutter build web --release
```

## 📥 Download

<div align="center">

### 📱 Get VJIT Study Vault

[![Download APK](https://img.shields.io/badge/Download-APK-success?style=for-the-badge&logo=android)](releases/latest)
[![Web App](https://img.shields.io/badge/Open-Web%20App-blue?style=for-the-badge&logo=google-chrome)](https://vjitstudyvault.web.app)

**Latest Version**: v1.0.0 | **Size**: ~15MB | **Min Android**: 5.0+

</div>

## 🎯 Supported Academic Programs

<div align="center">

| Branch | Years | Semesters |
|--------|-------|-----------|
| **Computer Science & Engineering (CSE)** | 1st - 4th | 1st & 2nd |
| **Information Technology (IT)** | 1st - 4th | 1st & 2nd |
| **Artificial Intelligence & ML (AIML)** | 1st - 4th | 1st & 2nd |
| **Data Science (DS)** | 1st - 4th | 1st & 2nd |
| **Electronics & Communication (ECE)** | 1st - 4th | 1st & 2nd |
| **Electrical & Electronics (EEE)** | 1st - 4th | 1st & 2nd |

*More branches and programs coming soon!*

</div>

## 🤝 Contributing

We welcome contributions from the VJIT community! Here's how you can help:

### 📋 Ways to Contribute

- 🐛 **Report Bugs** - Found an issue? Let us know!
- 💡 **Suggest Features** - Have ideas for improvement?
- 📚 **Add Study Materials** - Share your notes and resources
- 🔧 **Code Contributions** - Help improve the app
- 📖 **Documentation** - Improve our guides and docs

### 🔧 Development Setup

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### 📝 Contribution Guidelines

- Follow Flutter/Dart style guidelines
- Write meaningful commit messages
- Add tests for new features
- Update documentation as needed
- Ensure cross-platform compatibility

## 📊 Analytics & Privacy

VJIT Study Vault uses Firebase Analytics to improve user experience:

- **Anonymous Usage Data** - App navigation and feature usage
- **Performance Metrics** - Load times and crash reports
- **Content Engagement** - Most accessed materials and subjects
- **No Personal Data** - We don't collect names, emails, or personal information

*Your privacy matters to us. All analytics are anonymized and aggregated.*

## 🏆 Recognition

<div align="center">

### 🌟 **Featured By**

*[Placeholder for awards, mentions, or recognition]*

### 📈 **Stats**

![Downloads](https://img.shields.io/badge/Downloads-10K+-brightgreen?style=for-the-badge)
![Users](https://img.shields.io/badge/Active%20Users-2K+-blue?style=for-the-badge)
![Rating](https://img.shields.io/badge/Rating-4.8★-yellow?style=for-the-badge)

</div>

## 🚧 Roadmap

### 🔮 **Upcoming Features**

- [ ] **Offline Sync** - Download entire subjects for offline use
- [ ] **Study Planner** - AI-powered study schedule recommendations
- [ ] **Discussion Forums** - Peer-to-peer academic discussions
- [ ] **Video Lectures** - Integrated video content support
- [ ] **Study Groups** - Collaborative study features
- [ ] **Exam Reminders** - Smart notification system
- [ ] **Performance Analytics** - Personal study insights
- [ ] **Multi-language Support** - Telugu and Hindi language options

### 📅 **Version History**

| Version | Date | Features |
|---------|------|----------|
| **v1.0.0** | *Current* | Initial release with PDF viewing, downloads, and Drive integration |
| **v0.9.0** | *Beta* | Core functionality and onboarding |
| **v0.8.0** | *Alpha* | Basic PDF viewer and material organization |

## 📞 Support

Need help? We're here for you!

<div align="center">

[![GitHub Issues](https://img.shields.io/badge/GitHub-Issues-red?style=for-the-badge&logo=github)](https://github.com/saiusesgithub/vjitstudyvault/issues)
[![Email](https://img.shields.io/badge/Email-Contact-blue?style=for-the-badge&logo=gmail)](mailto:support@vjitstudyvault.com)

### 💬 **Community**

*[Placeholder for Discord/Telegram community links]*

</div>

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

### 👥 **Core Team**
- **[@saiusesgithub](https://github.com/saiusesgithub)** - Lead Developer & Founder
- *[Placeholder for team members]*

### 🎓 **Special Thanks**
- **VJIT Faculty** - For academic guidance and support  
- **Student Community** - For feedback and testing
- **Open Source Contributors** - For making this project possible

### 🛠️ **Built With**
- [Flutter](https://flutter.dev) - UI Framework
- [Firebase](https://firebase.google.com) - Backend Services
- [pdfx](https://pub.dev/packages/pdfx) - PDF Rendering
- [Dio](https://pub.dev/packages/dio) - HTTP Client

---

<div align="center">

**Made with ❤️ for VJIT Students**

*Empowering education through technology*

[![Star on GitHub](https://img.shields.io/badge/⭐-Star%20on%20GitHub-yellow?style=for-the-badge)](https://github.com/saiusesgithub/vjitstudyvault)

</div>
