# SAP Print Preview SmartForms

App to preview SmartForms in browser using RAP backend and Fiori frontend.

## Overview

Application for previewing SmartForms output directly in a web browser without SAP GUI.

## Project Structure

```
SAP-PrintPreviewSF/
├── RAP Backend/          # ABAP code (CDS, behavior, service)
└── Fiori Frontend/       # UI5 Fiori app
```

## How it Works

### Backend
- RAP with ABAP CDS views
- Calls SmartForms function module
- Generates PDF

### Frontend
Two ways to preview:

**1. Fiori Elements Standard**
- Uses hyperlink
- PDF opens in same tab

**2. Fiori Freestyle Extension**
- Custom button "Print Preview"
- Uses controller extension
- PDF opens in new tab

## Setup

### Backend
1. Import ABAP objects from `RAP Backend` folder
2. Activate all objects
3. Publish OData service

### Frontend
1. Deploy Fiori app from `Fiori Frontend` folder
2. Configure in Fiori Launchpad
3. Connect to OData service

## Usage

1. Open app from Fiori Launchpad
2. Select SmartForm to preview
3. Click preview button (freestyle) or link (standard)
4. View PDF in browser
