# Technical Documentation Suite
This repository is dedicated to the development of a technical documentation suite that offers essential tools for technical writers and documentation professionals. My goal is to incorporate enterprise-level features and functionality into an open-source solution that can be deployed on-premise by organizations and individuals. I intend for this solution to be compatible with all three major operating systems, preventing compatibility conflicts from excluding potential users.

The system will be based around the [DocBook XML](https://docbook.org) content model.

I hope to incorporate the following features:
- Full automation of the publishing process
- WYSIWYM and plain text editors
- Git version control of document source files
- Custom validation rules via Schematron
- Translation management support using XLIFF
- Collaborative authoring (when deployed on server with SSH)

**NOTE:** This is still in ***very*** early stages of planning, so the README is primarily dedicated to development notes at this time.

## System architecture
The notes below are not exhaustive. I will be updating as the project progresses.

### Libraries & dependencies
- XML content model: DocBook 5.0.1
    - I fully intend to support later versions, but I've experienced issues with v5.1 that I need to troubleshoot before adopting. These issues were likely due to incompatibility with a toolchain I used previously, given v5.1 is a stable release.
- XSLT stylesheets: DocBook XSL 1.79.1
- XSLT processor: xsltproc
- XSL-FO processor: Apache FOP
- Image optimizer: optipng
- Custom validation rules: Schematron
- Version control: Git
- Publishing automation framework: SCons
- Primary database for content storage: MongoDB
- DB interactions: PyMongo
- Python interpreter: Python 3.x
- JRE/JDK: OpenJDK (version TBD)

### Custom code
- Database content schemas (may use directory-based storage for some of these, TBD)
    - XSLT customizations
    - Schematron rules
    - DocBook XML content
    - Images
    - Font files
    - Configuration files
    - Document trees (hierarchical arrangements of XML contents for publishable documents)
- Abstraction of file access from DB for processors
    - For processors that anticipate directory-based systems - research this for each external processor
- Automated image optimization
    - Study the actual impact optipng has on filesize - even in best case, this is lower priority
    - Include metadata for each image indicating present optimization level - notify user of sub-optimal level when publishing
- Content validation
    - Well-formed XML
    - Valid against DocBook schema
    - Valid against custom rules (Schematron)
- Publishing automations (using SCons framework)
    - Build profiled document
    - Document transformation into publishable formats (and intermediary formats if required)
- XLIFF transformations for translation management
    - Investigate possibility of integrations with translation management systems
    - Unique IDs will be required for each element to facilitate mapping of tranlated XLIFF content back to DocBook structure
    - Additional solution will be needed for text contained within image files
- GUI
    - Overall system interface
    - XSLT customization GUI
    - Text editor (if no suitable external solution)
    - WYSIWYM editor for DocBook content
- Extensions for third-party applications
    - VS Code (my favorite free text editor for DocBook XML authoring)

### Investigate external solutions
- Plain text/code editor
- GUI framework
- GUI SVG editor
    - To facilitate maintenance and translation of text labels within technical illustrations - this would likely be a complex feature to incorporate, but potentially worthwhile

## Developer tools
This is a quick overview of some of the tools I'm using, or plan to use, for development of this project. These are notes to self, more than anything, so excuse my thinking out loud.

- Text editor & extensions
    - VS Code
- Database tools
    - MongoDB shell (`mongosh`)
    - Robo 3T
    - MongoDB Compass
    - MySQL Workbench (for any relational DB needs that arise)