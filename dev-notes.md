# Development notes

## Developer tools
This is a quick overview of some of the tools I'm using, or plan to use, for development of this project. I'll put together a VS Code extension pack for development at some point.

- Text editor & extensions
    - VS Code
        - github.remotehub
        - github.vscode-pull-request-github
        - mongodb.mongodb-vscode
        - ms-python.isort
        - ms-python.python
        - ms-vscode.remote-explorer
        - ms-vscode.remote-repositories
        - ms-vscode-remote.remote-wsl
        - redhat.java
        - redhat.vscode-xml
        - vscode.powershell
- Database tools
    - MongoDB server
    - MongoDB shell (`mongosh`)
    - MongoDB Compass
    - MySQL Workbench (for any relational DB needs that arise)

## Investigate external solutions
Look for existing tools or libraries for these features so we don't have to develop from scratch.

- Plain text/code editor
- GUI SVG editor
    - To facilitate maintenance and translation of text labels within technical illustrations - this would likely be a complex feature to incorporate, but potentially worthwhile

## Custom code to develop
This has not been updated as recently as README.md, so review the architecture notes there for more current information.

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