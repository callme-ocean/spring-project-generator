# Spring Boot Project Generator

![Project Logo](https://raw.githubusercontent.com/callme-ocean/callme-ocean/main/projectScreenshots/springBootProjectGenerator/springBootProjectGenerator_img1.png)

[![License: AGPL v3](https://img.shields.io/badge/License-AGPL--v3-blue.svg?style=for-the-badge&logoSize=auto)](https://www.gnu.org/licenses/agpl-3.0.html)
[![Buy Me a Coffee](https://img.shields.io/badge/buy_me_a_coffee-fd6744?logo=buy-me-a-coffee&logoColor=white&style=for-the-badge&logoSize=auto)](https://buymeacoffee.com/sagarb)


_Empower your team to spin up fully‑configured, best‑practice Spring microservices in seconds—complete with layered packages, REST endpoint stubs, AOP logging, exception handling, flexible Java versions, and more. Consistency, speed, and maintainability at your fingertips._


## 🌐 Live Project

Try out the live generator here:

🔗 **[Spring Boot Project Generator](https://spring-boot-project-generator.oceanbytes.in/api/spring-project-generator/v1/generator)**


## ✨ Features

- Generate a complete Spring Boot 3 project scaffold in ZIP format
- Select from common packages like `controllers`, `services`, `repositories`, etc.
- Choose which REST APIs to include: `GET`, `POST`, `PUT`, `DELETE`
- Pick Java version (17 or 21) for your new project
- Auto‑generate boilerplate (controllers, exceptions, logging, constants)
- Adds `.gitignore`, `application.yml`, `pom.xml` with dynamic group/artifact IDs


## 🧠 How It Works

### 1. Scaffolds a Spring Boot 3 Project

- Creates the entire Maven structure (`pom.xml`, `src/main/java`, `src/main/resources`, tests, etc.).
- Populates `pom.xml` with Spring Boot’s parent, web & test dependencies, plus your chosen Java version.

### 2. Pre-Wires Common Layers

You pick which packages you want (controllers, services, repositories, models, exceptions, constants, aspects, utils,
etc.), and the tool:

- Creates empty package directories for each.
- Generates a sample controller (with GET/POST/PUT/DELETE methods if you asked).
- Drops in an AOP logging aspect for consistent request tracing.
- Builds out exception types (`ServiceException`, `ErrorDetails`) and a global handler.
- Adds a `constants` class stub ready for your app-wide values.

### 3. Auto-Generates Config & Boilerplate

- Writes an `application.yml` with sensible defaults (server port, context path).
- Injects your project & group name into package declarations, class names, and Maven coordinates.
- Includes a `.gitignore` tuned for Java IDEs and Maven build artifacts.

### 4. Flexible Java Version

- Choose Java 17 or Java 21 at generation time, and the `pom.xml` adapts automatically.

### 5. Clean, Modular Scripts

- Under the hood, a set of small, well-organized shell scripts each handle one concern (directories, configs, classes).
- Easy to extend—add new templates or tweak outputs without monolithic scripts.


## 🚀 How It Accelerates Microservice Development

- **Eliminates “First Commit” Busywork**
  </br>Every new microservice needs the same basic folder layout, POM, main class, logging, exception patterns, and
  build config. Doing that by hand for each new service is error-prone and tedious. This tool does it in seconds.

- **Enforces Consistent Best Practices**
  </br>Out-of-the-box, you get:
    - Package-per-layer structure (Controllers, Services, Repositories, etc.)
    - Exception handling boilerplate ready to customize
    - AOP logging wired for all REST endpoints
    - Standard `.gitignore`, logging levels, context paths
    - Maven parent inheritance & version management
      </br>That consistency makes it easier for teams to jump between services without hunting for where things live.

- **Reduces Onboarding Friction**
  </br>New team members can generate a skeleton, run it locally, see “Hello World,” and then start coding—avoiding a
  steep ramp-up on internal conventions.

- **Streamlines DevOps & CI/CD**
  </br>Because each service starts from the same template, integrating new microservices into your pipelines, Docker
  builds, and Kubernetes manifests becomes a repeatable process.


## 🎯 Day-to-Day Benefit

1. **One Click, Zero Typo**
   </br>No more copy-pasting last service’s folders and manually renaming packages.

2. **Template-Driven**
   </br>Need a new layer (e.g. “metrics”)? Just add it to `application.yml` and rebuild—no Java changes required.

3. **Config-First**
   </br>Changing ports, context paths, Java versions, or default APIs is as easy as editing a YAML or flipping a radio
   button.

4. **Rapid Prototyping**
   </br>Spin up sandbox services for PoCs in seconds, with all the standard plumbing ready.


## 📸 Screenshots

<details>
<summary>Expand to view screenshots</summary>

|                     Home Page                      |
|:--------------------------------------------------:|
|      ![Home Page](https://raw.githubusercontent.com/callme-ocean/callme-ocean/main/projectScreenshots/springBootProjectGenerator/springBootProjectGenerator_img1.png)       | 


</details>


## 📦 Installation

### 🔧 Prerequisites

- Java 17+ (to run the generator service)
- Maven 3.6+
- Bash shell (Linux/macOS) or Git Bash (Windows)

```bash
# Clone the repo
git clone https://github.com/callme-ocean/spring-project-generator.git
cd spring-project-generator

# Build the service
mvn clean package

# Run locally
java -jar target/spring-project-generator-1.0.0-SNAPSHOT.jar
```

Then open your browser at `http://localhost:8080/api/spring-project-generator/v1/generator`.


## 🧪 Usage Guide

1. Navigate to the **Generator** UI.
2. Enter **Project Name** (e.g., `my-service`).
3. Enter **Group Name** (e.g., `com.example`).
4. Select desired **Packages**.
5. Choose which **APIs** to include.
6. Pick **Java Version** via radio buttons.
7. Click **Generate Project**.
8. Your ZIP scaffold downloads instantly.

Inside the ZIP you’ll find:

```
├── src/
│   ├── main/java/com/example/myservice/...
│   └── main/resources/application.yml
├── pom.xml
└── .gitignore
```


## ⚙️ Tech Stack

- **Frontend**: Thymeleaf, HTML, CSS
- **Backend**: Spring boot, Java
- **Deployment**: Render

## 📄 License

This project is licensed under the [GNU Affero General Public License version 3 (AGPLv3)](https://www.gnu.org/licenses/agpl-3.0.html).


## 🤝 Contributing

Contributions are welcome! </br>
Please feel free to submit pull requests to improve features, fix bugs, or suggest enhancements.

## 📜 Credits for Derivatives

If you create a new project or application by modifying or building on top of this code, please include the following in your README:

> This project is based on [Spring Boot Project Generator](https://github.com/your-username/your-repo-name) created by Sagar Bhadouria </br>
> Licensed under the [AGPLv3](https://www.gnu.org/licenses/agpl-3.0.html).

This helps preserve proper attribution while complying with AGPLv3’s notice-preservation requirements.

## 🤔 Future Steps

- Improve UI.