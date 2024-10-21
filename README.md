# Snakefarm CCMS: Open-Source Technical Documentation Suite
This repository is dedicated to the development of a technical documentation suite that offers essential tools for technical writers and documentation professionals. My goal is to incorporate enterprise-level features and functionality into an open-source solution that can be deployed on-premise by organizations and individuals. I intend for this solution to be compatible with all three major operating systems, preventing compatibility conflicts from excluding potential users.

The system will be based around the [DocBook XML](https://docbook.org) content model.

I plan to incorporate the following features:
- Full automation of the publishing process
- WYSIWYM and plain text (code) editors
- Git version control of document source files
- Custom validation rules via Schematron
- Translation management support using XLIFF
- Collaborative authoring (when deployed on remote server)

## System architecture
The notes below are not exhaustive. I will be updating as the project progresses.

Ultimately, Snakefarm CCMS will be composed of a server application and a client application, enabling deployment either as a single-host desktop setup, where both the server and client run locally, or as a distributed setup with the server on a remote server and the client on user machines.

The server application will also support headless deployments, where core functionality will be accessible via the server's CLI (and potentially API). I am interested in developing VS Code extensions to facilitate usage in headless deployments.

A web client may be worth exploring once the server and desktop client have reached a stable, production-ready status.

The server application consists of the following modules:
- **Data:** MongoDB database containing all user content, build data and formatting data.
- **DB-Interact:** Database management engine built in Python environment. Utilizes PyMongo library to manage all interactions with MongoDB database. Automates optipng utility to optimize uploaded images. Utilizes Git for version control. CLI and Flask API.
- **Pipeline:** Document validation and transformation engine built in Python environment with Java installed. Utilizes either the SCons library or simpler custom scripts to automate the transformation of content from source format into externally usable formats such as HTML, PDF, and XLIFF. Apache FOP and xsltproc are the two main processors that handle actual document transformation. CLI and Flask API.

The client application will be built in Java, utilizing either the Swing or JavaFX framework. It consists of the following modules:
- **GUI-Core:** The main user interface.
- **Text-Editor:** Code-level editing of DocBook content (and, potentially, XSLT customizations). Will also need strict validation, so maybe the Doc-Editor module should be an abstraction layer over this one. This would ensure validation logic is kept within one module of the GUI.
- **Doc-Editor:** Visual WYSIWYM-style editor. Will likely incorporate xsltproc and Apache FOP for real-time validation and stylesheet previewing.
- **Image-Editor:** Visual SVG editor, facilitating diagramming and offering in-app control of diagram elements. Similar concept to anchored frame in FrameMaker. DocBook doesn't support DocBook elements within SVG imageobjects, so implementing control of diagram labels will require some creative problem solving.
- **Terminal:** In-app terminal for direct access to server application's CLI.

Additional tools that will likely be added to project scope later on:
- **IDE/text editor extensions:** Develop VS Code extensions or extension packs to facilitate authoring in headless deployments.
- **Web client:** Explore development of web client for snakefarm core, leaning on Flask APIs for xml/xsl processing. Achieving real-time content validation with this interface may be tricky since we don't have xsltproc and fop at the frontend's disposal.

## Libraries & dependencies
- XML content model: DocBook 5.0.1
    - I fully intend to support later versions, but I've experienced issues with v5.1 that I need to troubleshoot before adopting. These issues were likely due to incompatibility with a toolchain I used previously, given v5.1 is a stable release.
- XSLT stylesheets: DocBook XSL 1.79.1
- XSLT processor: xsltproc
- XSL-FO processor: Apache FOP
- Image optimizer: optipng
- Custom validation rules: Schematron
- Version control: Git
- Primary database for content storage: MongoDB
- DB interactions: PyMongo
- Publishing automation framework: SCons
- Python APIs: Flask
- Python interpreter: Python 3.10
- JRE/JDK: OpenJDK 17
- GUI framework: JavaFX *or* Swing
