CLASS zzcl_dn_pdf_qry DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    " Standard Smart Forms Paramaters
    DATA: gv_formname           TYPE tdsfname,
          gv_fm_name            TYPE rs38l_fnam,
          gs_control_parameters TYPE ssfctrlop,
          gs_output_options     TYPE ssfcompop,
          gs_job_output_info    TYPE ssfcrescl,
          gt_errortab           TYPE tsferror.

    " Customized Smart Forms Parameters
    DATA: gs_header   TYPE zs47820_dnheader,
          gt_item     TYPE ztt47820_dnitems,
          gs_item     TYPE zs47820_dnitems,
          gt_footaddr TYPE tsftext,
          gs_footaddr TYPE tline.

    INTERFACES if_rap_query_provider .
  PROTECTED SECTION.
  PRIVATE SECTION.
    METHODS build_pdf
      IMPORTING
        iv_vbeln      TYPE vbeln
      RETURNING
        VALUE(rv_pdf) TYPE xstring.
ENDCLASS.



CLASS zzcl_dn_pdf_qry IMPLEMENTATION.


  METHOD if_rap_query_provider~select.

    "✅ Always cover paging (even if you return nothing)
    DATA(lo_paging)   = io_request->get_paging( ).
    DATA(lv_top)      = lo_paging->get_page_size( ).
    DATA(lv_skip)     = lo_paging->get_offset( ).

    "Good practice: cover filter too (you use it)
    DATA(lo_filter)   = io_request->get_filter( ).
    DATA(lt_ranges)   = lo_filter->get_as_ranges( ).

    DATA lv_vbeln TYPE vbeln.
    READ TABLE lt_ranges WITH KEY name = 'DELIVERYDOCUMENT' INTO DATA(ls_vbeln_rng).
    IF sy-subrc = 0 AND ls_vbeln_rng-range IS NOT INITIAL.
      lv_vbeln = ls_vbeln_rng-range[ 1 ]-low.
    ENDIF.

    DATA lt_data TYPE STANDARD TABLE OF zzc_dn_pdf_preview.

    "✅ If no key/filter provided: return empty set, but AFTER calling get_paging
    IF lv_vbeln IS INITIAL.
      io_response->set_data( lt_data ).
      io_response->set_total_number_of_records( 0 ).
      RETURN.
    ENDIF.

    "Generate PDF
    DATA(lv_pdf) = build_pdf( lv_vbeln ). "-> XSTRING

    APPEND VALUE #( deliverydocument = lv_vbeln
                    mimetype         = 'application/pdf'
                    filename         = |{ lv_vbeln }-Delivery Note.pdf|
                    filecontent      = lv_pdf ) TO lt_data.

    io_response->set_data( lt_data ).
    io_response->set_total_number_of_records( 1 ).

  ENDMETHOD.



  METHOD build_pdf.
    CLEAR: gs_header, gt_item, gt_footaddr.

    " Get Header Data
    SELECT SINGLE inco1, inco2, route, vbeln,
                  lfdat, wadat, wauhr, kunag, kunnr
      FROM likp
      WHERE vbeln = @iv_vbeln
      INTO @gs_header.

    IF sy-subrc <> 0.
      "No Header Found
      RETURN.
    ENDIF.

    " Get Items Data
    SELECT vbeln, posnr, matnr, lips~mtart, mtbez,
           arktx, lfimg, lgmng
      FROM lips LEFT OUTER JOIN t134t
        ON lips~mtart = t134t~mtart
      WHERE vbeln = @iv_vbeln
        AND spras = @sy-langu
      INTO CORRESPONDING FIELDS OF TABLE @gt_item.

    IF sy-subrc <> 0.
      "No Items Found
      RETURN.
    ENDIF.


*** Get Address Data for Smartforms
    DATA: lt_fes_address TYPE vbadr.

    SELECT SINGLE adrnr, name1, stras, mcod3, land1, pstlz, telf1
      FROM lfa1
      INTO @DATA(ls_supplier)
      WHERE kunnr = @gs_header-kunnr.

    IF sy-subrc <> 0.
      CALL FUNCTION 'SD_ADDRESS_GET'
        EXPORTING
          fif_address_number      = '0000023880' " Table ADRC
          fif_personal_number     = '0000023903' " Table ADRP
        IMPORTING
          fes_address             = lt_fes_address
        EXCEPTIONS
          address_not_found       = 1
          address_type_not_exists = 2
          no_person_number        = 3
          OTHERS                  = 4.
      IF sy-subrc <> 0.
        "Address Not Found
      ENDIF.
    ELSE.
      CALL FUNCTION 'SD_ADDRESS_GET'
        EXPORTING
          fif_address_number      = ls_supplier-adrnr
        IMPORTING
          fes_address             = lt_fes_address
        EXCEPTIONS
          address_not_found       = 1
          address_type_not_exists = 2
          no_person_number        = 3
          OTHERS                  = 4.
      IF sy-subrc <> 0.
        "Address Not Found
      ENDIF.
    ENDIF.

    IF ls_supplier IS NOT INITIAL.
      gs_footaddr-tdformat = '1'.
      gs_footaddr-tdline   = ls_supplier-name1.
      APPEND gs_footaddr TO gt_footaddr.
      CLEAR: gs_footaddr.

      gs_footaddr-tdformat = '2'.
      CONCATENATE ls_supplier-stras ls_supplier-mcod3
                  INTO gs_footaddr-tdline SEPARATED BY ', '.
      APPEND gs_footaddr TO gt_footaddr.
      CLEAR: gs_footaddr.

      gs_footaddr-tdformat = '3'.
      CONCATENATE ls_supplier-land1 ls_supplier-pstlz
                  INTO gs_footaddr-tdline SEPARATED BY ', '.
      APPEND gs_footaddr TO gt_footaddr.
      CLEAR: gs_footaddr.

      gs_footaddr-tdformat = '4'.
      gs_footaddr-tdline   = '<%W>+' && ls_supplier-telf1 && '</>'.
      APPEND gs_footaddr TO gt_footaddr.
      CLEAR: gs_footaddr.

      gs_footaddr-tdformat = '5'.
      gs_footaddr-tdline = '<%W>' && lt_fes_address-email_addr && '</>'.
      APPEND gs_footaddr TO gt_footaddr.
      CLEAR: gs_footaddr.
    ELSE.
      gs_footaddr-tdformat = '1'.
      gs_footaddr-tdline   = 'SAP Technical Team'.
      APPEND gs_footaddr TO gt_footaddr.
      CLEAR: gs_footaddr.

      gs_footaddr-tdformat = '2'.
      gs_footaddr-tdline   = 'PT Hand Solutions Indonesia'.
      APPEND gs_footaddr TO gt_footaddr.
      CLEAR: gs_footaddr.

      gs_footaddr-tdformat = '3'.
      gs_footaddr-tdline   = 'Tatapuri Building 6th Floor'.
      APPEND gs_footaddr TO gt_footaddr.
      CLEAR: gs_footaddr.

      gs_footaddr-tdformat = '4'.
      gs_footaddr-tdline   = 'Jl. Tanjung Karang 3-4A, Kebon Melati, Jakarta 10230'.
      APPEND gs_footaddr TO gt_footaddr.
      CLEAR: gs_footaddr.

      gs_footaddr-tdformat = '5'.
      gs_footaddr-tdline = '<%W>' && lt_fes_address-email_addr && '</>'.
      APPEND gs_footaddr TO gt_footaddr.
      CLEAR: gs_footaddr.
    ENDIF.



*** Get the OTF of the Generated document
    gv_formname = 'ZSF47820_SMARTFORMS'.

    CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
      EXPORTING
        formname           = gv_formname
      IMPORTING
        fm_name            = gv_fm_name
      EXCEPTIONS
        no_form            = 1
        no_function_module = 2
        OTHERS             = 3.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

    gs_control_parameters-getotf  = abap_true. " Get OTF
    gs_output_options-tdimmed     = abap_true. "no spool dialog
    gs_output_options-tddelete    = abap_true. "cleanup spool
    gs_output_options-tddest      = 'LP01'.

    CLEAR: gs_job_output_info.
    CALL FUNCTION gv_fm_name
      EXPORTING
        control_parameters = gs_control_parameters
        output_options     = gs_output_options
        user_settings      = ''
        is_header          = gs_header
        it_footaddr        = gt_footaddr
      IMPORTING
        job_output_info    = gs_job_output_info
      TABLES
        it_item            = gt_item
      EXCEPTIONS
        formatting_error   = 1
        internal_error     = 2
        send_error         = 3
        user_canceled      = 4
        OTHERS             = 5.
    IF sy-subrc <> 0.
      CALL FUNCTION 'SSF_READ_ERRORS'
        IMPORTING
          errortab = gt_errortab.
      READ TABLE gt_errortab ASSIGNING
                              FIELD-SYMBOL(<fs_errortab>) INDEX 1.
      IF sy-subrc = 0.
        MESSAGE ID <fs_errortab>-msgid
                TYPE 'E'
                NUMBER <fs_errortab>-msgno
                WITH <fs_errortab>-msgv1 <fs_errortab>-msgv2
                     <fs_errortab>-msgv3 <fs_errortab>-msgv4
                DISPLAY LIKE 'W'.
      ENDIF.
    ENDIF.
    CLEAR: gs_control_parameters, gs_output_options.

*** Convert OTF to xstring
    DATA: lv_pdf_xstring TYPE xstring,
          lt_pdf_lines   TYPE STANDARD TABLE OF tline,
          lt_doctab      TYPE STANDARD TABLE OF docs.

    CALL FUNCTION 'CONVERT_OTF'
      EXPORTING
        format                = 'PDF'
      IMPORTING
        bin_file              = lv_pdf_xstring
      TABLES
        otf                   = gs_job_output_info-otfdata
        lines                 = lt_pdf_lines
      EXCEPTIONS
        err_max_linewidth     = 1
        err_format            = 2
        err_conv_not_possible = 3
        OTHERS                = 4.

    IF sy-subrc <> 0.
      " Conversion Error
      RETURN.
    ENDIF.

    rv_pdf = lv_pdf_xstring.

  ENDMETHOD.

ENDCLASS.
