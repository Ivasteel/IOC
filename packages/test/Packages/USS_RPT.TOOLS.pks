/* Formatted on 8/12/2025 5:58:56 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_RPT.TOOLS
IS
    -- Author  : ivashchuk
    -- Created : 22.04.2019

    FUNCTION ConvertC2B (p_src CLOB)
        RETURN BLOB;

    FUNCTION ConvertB2C (p_src BLOB)
        RETURN CLOB;

    FUNCTION PasteClob (p_dest CLOB, p_ins_data CLOB, p_signature VARCHAR2)
        RETURN CLOB;

    FUNCTION PasteBlob (p_dest BLOB, p_ins_data BLOB, p_signature VARCHAR2)
        RETURN BLOB;

    FUNCTION encode_base64 (p_blob_in IN BLOB)
        RETURN CLOB;

    FUNCTION decode_base64 (p_clob_in IN CLOB)
        RETURN BLOB;

    FUNCTION utf8todeflang (p_clob IN CLOB)
        RETURN CLOB;

    --PROCEDURE Sleep(p_sec NUMBER);
    -- Âטנ³חא÷למ פנאדלועם ךמכבא ג ³םרטי ךכמב
    FUNCTION get_clob_substr (p_clob CLOB, p_start NUMBER, p_stop NUMBER)
        RETURN CLOB;

    FUNCTION deflangtoutf8 (p_clob IN CLOB)
        RETURN CLOB;

    PROCEDURE HANDLE_DNET_CONNECTION (p_session_id     VARCHAR2,
                                      p_absolute_url   VARCHAR2);

    FUNCTION GetHistSession (p_hs_wu histsession.hs_wu%TYPE:= NULL)
        RETURN histsession.hs_id%TYPE;

    FUNCTION GetCurrOrg
        RETURN NUMBER;

    FUNCTION GetCurrOrgTo
        RETURN NUMBER;
END TOOLS;
/


GRANT EXECUTE ON USS_RPT.TOOLS TO DNET_PROXY
/

GRANT EXECUTE ON USS_RPT.TOOLS TO II01RC_USS_RPT_WEB
/


/* Formatted on 8/12/2025 5:59:00 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_RPT.TOOLS
IS
    FUNCTION ConvertC2B (p_src CLOB)
        RETURN BLOB
    IS
        l_clob_offset    INTEGER;
        l_blob_offset    INTEGER;
        l_lang_context   INTEGER;
        l_convert_warn   INTEGER;

        l_result         BLOB;
    BEGIN
        l_clob_offset := 1;
        l_blob_offset := 1;
        l_lang_context := DBMS_LOB.default_lang_ctx;

        DBMS_LOB.createtemporary (l_result, TRUE);
        DBMS_LOB.convertToBlob (l_result,
                                p_src,
                                DBMS_LOB.lobmaxsize,
                                l_blob_offset,
                                l_clob_offset,
                                DBMS_LOB.default_csid,
                                l_lang_context,
                                l_convert_warn);

        RETURN l_result;
    END;

    FUNCTION ConvertB2C (p_src BLOB)
        RETURN CLOB
    IS
        l_clob           CLOB;
        l_dest_offsset   INTEGER := 1;
        l_src_offsset    INTEGER := 1;
        l_lang_context   INTEGER := DBMS_LOB.default_lang_ctx;
        l_warning        INTEGER;
    BEGIN
        IF p_src IS NULL
        THEN
            RETURN NULL;
        END IF;

        DBMS_LOB.createTemporary (lob_loc => l_clob, cache => FALSE);

        DBMS_LOB.converttoclob (dest_lob       => l_clob,
                                src_blob       => p_src,
                                amount         => DBMS_LOB.lobmaxsize,
                                dest_offset    => l_dest_offsset,
                                src_offset     => l_src_offsset,
                                blob_csid      => DBMS_LOB.default_csid,
                                lang_context   => l_lang_context,
                                warning        => l_warning);

        RETURN l_clob;
    END;


    FUNCTION PasteClob (p_dest CLOB, p_ins_data CLOB, p_signature VARCHAR2)
        RETURN CLOB
    IS
        l_result   CLOB;
        i          INTEGER;
        LN         INTEGER;
        i_start    INTEGER;
        i_stop     INTEGER;
    BEGIN
        i := 1;
        LN := DBMS_LOB.getlength (p_dest);

        DBMS_LOB.createTemporary (l_result, TRUE);
        DBMS_LOB.OPEN (l_result, DBMS_LOB.LOB_ReadWrite);

        WHILE i < LN
        LOOP
            i_start :=
                DBMS_LOB.INSTR (p_dest,
                                p_signature,
                                i,
                                1);

            IF i_start > 0
            THEN
                i_stop := i_start + LENGTH (p_signature) - 1;
                DBMS_LOB.writeappend (
                    l_result,
                    i_start - i,
                    DBMS_LOB.SUBSTR (p_dest, i_start - i, i));
                DBMS_LOB.append (l_result, p_ins_data);
                i := i_stop + 1;
            ELSE
                DBMS_LOB.writeappend (
                    l_result,
                    LN - i + 1,
                    DBMS_LOB.SUBSTR (p_dest, LN - i + 1, i));
                i := LN;
            END IF;
        END LOOP;

        RETURN l_result;
    END;

    FUNCTION PasteBlob (p_dest BLOB, p_ins_data BLOB, p_signature VARCHAR2)
        RETURN BLOB
    IS
        l_result   BLOB;
        i          INTEGER;
        LN         INTEGER;
        i_start    INTEGER;
        i_stop     INTEGER;
    BEGIN
        i := 1;
        LN := DBMS_LOB.getlength (p_dest);

        DBMS_LOB.createTemporary (l_result, TRUE);
        DBMS_LOB.OPEN (l_result, DBMS_LOB.LOB_ReadWrite);

        WHILE i < LN
        LOOP
            i_start :=
                DBMS_LOB.INSTR (p_dest,
                                UTL_RAW.cast_to_raw (p_signature),
                                i,
                                1);

            IF i_start > 0
            THEN
                i_stop :=
                    i_start + LENGTH (UTL_RAW.cast_to_raw (p_signature)) - 1;
                DBMS_LOB.writeappend (
                    l_result,
                    i_start - i,
                    DBMS_LOB.SUBSTR (p_dest, i_start - i, i));
                DBMS_LOB.append (l_result, p_ins_data);
                i := i_stop + 1;
            ELSE
                DBMS_LOB.writeappend (l_result,
                                      LN - i,
                                      DBMS_LOB.SUBSTR (p_dest, LN - i, i));
                i := LN;
            END IF;
        END LOOP;

        RETURN l_result;
    END;

    FUNCTION encode_base64 (p_blob_in IN BLOB)
        RETURN CLOB
    IS
        v_clob             CLOB;
        v_result           CLOB;
        v_offset           INTEGER;
        v_chunk_size       BINARY_INTEGER := (48 / 4) * 3;
        v_buffer_varchar   VARCHAR2 (48);
        v_buffer_raw       RAW (48);
    BEGIN
        IF p_blob_in IS NULL
        THEN
            RETURN NULL;
        END IF;

        DBMS_LOB.createtemporary (v_clob, TRUE);
        v_offset := 1;

        FOR I IN 1 .. CEIL (DBMS_LOB.getlength (p_blob_in) / v_chunk_size)
        LOOP
            DBMS_LOB.read (p_blob_in,
                           v_chunk_size,
                           v_offset,
                           v_buffer_raw);
            v_buffer_raw := UTL_ENCODE.base64_encode (v_buffer_raw);
            v_buffer_varchar := UTL_RAW.cast_to_varchar2 (v_buffer_raw);
            DBMS_LOB.writeappend (v_clob,
                                  LENGTH (v_buffer_varchar),
                                  v_buffer_varchar);
            v_offset := v_offset + v_chunk_size;
        END LOOP;

        v_result := v_clob;
        DBMS_LOB.freetemporary (v_clob);
        RETURN v_result;
    END encode_base64;


    FUNCTION decode_base64 (p_clob_in IN CLOB)
        RETURN BLOB
    IS
        v_blob             BLOB;
        v_result           BLOB;
        v_offset           INTEGER;
        v_buffer_size      BINARY_INTEGER := 48;
        v_buffer_varchar   VARCHAR2 (48);
        v_buffer_raw       RAW (48);
    BEGIN
        IF p_clob_in IS NULL
        THEN
            RETURN NULL;
        END IF;

        DBMS_LOB.createtemporary (v_blob, TRUE);
        v_offset := 1;

        FOR I IN 1 .. CEIL (DBMS_LOB.getlength (p_clob_in) / v_buffer_size)
        LOOP
            DBMS_LOB.read (p_clob_in,
                           v_buffer_size,
                           v_offset,
                           v_buffer_varchar);
            v_buffer_raw := UTL_RAW.cast_to_raw (v_buffer_varchar);
            v_buffer_raw := UTL_ENCODE.base64_decode (v_buffer_raw);
            DBMS_LOB.writeappend (v_blob,
                                  UTL_RAW.LENGTH (v_buffer_raw),
                                  v_buffer_raw);
            v_offset := v_offset + v_buffer_size;
        END LOOP;

        v_result := v_blob;
        DBMS_LOB.freetemporary (v_blob);
        RETURN v_result;
    END decode_base64;

    FUNCTION utf8todeflang (p_clob IN CLOB)
        RETURN CLOB
    IS
        l_blob            BLOB;
        l_clob            CLOB;
        l_dest_offset     INTEGER := 1;
        l_source_offset   INTEGER := 1;
        l_lang_context    INTEGER := DBMS_LOB.DEFAULT_LANG_CTX;
        l_warning         INTEGER := DBMS_LOB.WARN_INCONVERTIBLE_CHAR;
    BEGIN
        DBMS_LOB.CREATETEMPORARY (l_blob, TRUE);
        DBMS_LOB.CONVERTTOBLOB (dest_lob       => l_blob,
                                src_clob       => p_clob,
                                amount         => DBMS_LOB.LOBMAXSIZE,
                                dest_offset    => l_dest_offset,
                                src_offset     => l_source_offset,
                                blob_csid      => 0,
                                lang_context   => l_lang_context,
                                warning        => l_warning);
        l_dest_offset := 1;
        l_source_offset := 1;
        l_lang_context := DBMS_LOB.DEFAULT_LANG_CTX;
        DBMS_LOB.CREATETEMPORARY (l_clob, TRUE);
        DBMS_LOB.CONVERTTOCLOB (dest_lob       => l_clob,
                                src_blob       => l_blob,
                                amount         => DBMS_LOB.LOBMAXSIZE,
                                dest_offset    => l_dest_offset,
                                src_offset     => l_source_offset,
                                blob_csid      => NLS_CHARSET_ID ('UTF8'),
                                lang_context   => l_lang_context,
                                warning        => l_warning);
        RETURN l_clob;
    END;

    /*
    PROCEDURE Sleep(p_sec NUMBER)
    IS
    BEGIN
      null;
      --dbms_lock.sleep(p_sec);
    END;
    */
    -- Âטנ³חא÷למ פנאדלועם ךמכבא ג ³םרטי ךכמב
    FUNCTION get_clob_substr (p_clob CLOB, p_start NUMBER, p_stop NUMBER)
        RETURN CLOB
    IS
        l_part           NUMBER;
        l_portion        NUMBER;
        l_new_clob       CLOB;
        l_buff           CLOB;
        l_portion_size   NUMBER := 10000;
    BEGIN
        DBMS_LOB.createtemporary (lob_loc => l_new_clob, CACHE => TRUE);
        DBMS_LOB.OPEN (lob_loc     => l_new_clob,
                       open_mode   => DBMS_LOB.lob_readwrite);
        --dbms_output.put_line('length(p_clob) = '||dbms_lob.getlength(p_clob));
        l_part := 1;

        --dbms_output.put_line('start:'||p_start);
        WHILE (p_start + (l_part - 1) * l_portion_size <                 /*=*/
                                                         p_stop)
        LOOP
            l_portion :=
                LEAST (l_portion_size,
                       p_stop - p_start - (l_part - 1) * l_portion_size);
            --  dbms_output.put_line((l_portion) ||' #############'||(p_start + (l_part-1)*2000)||'-'||(p_start + l_part*2000));
            l_buff :=                             /*utl_raw.cast_to_varchar2*/
                (DBMS_LOB.SUBSTR (p_clob,
                                  l_portion,
                                  p_start + (l_part - 1) * l_portion_size));
            --dbms_output.put_line(dbms_lob.substr(p_clob, l_portion ,p_start + (l_part-1)*2000 ));
            --  dbms_output.put_line(l_buff);
            l_part := l_part + 1;
            DBMS_LOB.writeappend (l_new_clob,
                                  DBMS_LOB.getlength ((l_buff)), /*utl_raw.cast_to_raw*/
                                  (l_buff));
        --dbms_output.put_line('length(l_new_clob) = '||dbms_lob.getlength(l_new_clob));
        END LOOP;

        --   dbms_output.put_line(l_new_clob);
        --dbms_output.put_line('final length(l_new_clob) = '||dbms_lob.getlength(l_new_clob));
        RETURN l_new_clob;
    END;

    FUNCTION deflangtoutf8 (p_clob IN CLOB)
        RETURN CLOB
    IS
        l_blob            BLOB;
        l_clob            CLOB;
        l_dest_offset     INTEGER := 1;
        l_source_offset   INTEGER := 1;
        l_lang_context    INTEGER := DBMS_LOB.DEFAULT_LANG_CTX;
        l_warning         INTEGER := DBMS_LOB.WARN_INCONVERTIBLE_CHAR;
    BEGIN
        DBMS_LOB.CREATETEMPORARY (l_blob, TRUE);
        DBMS_LOB.CONVERTTOBLOB (dest_lob       => l_blob,
                                src_clob       => p_clob,
                                amount         => DBMS_LOB.LOBMAXSIZE,
                                dest_offset    => l_dest_offset,
                                src_offset     => l_source_offset,
                                blob_csid      => NLS_CHARSET_ID ('UTF8'),
                                lang_context   => l_lang_context,
                                warning        => l_warning);
        l_dest_offset := 1;
        l_source_offset := 1;
        l_lang_context := DBMS_LOB.DEFAULT_LANG_CTX;
        DBMS_LOB.CREATETEMPORARY (l_clob, TRUE);
        DBMS_LOB.CONVERTTOCLOB (dest_lob       => l_clob,
                                src_blob       => l_blob,
                                amount         => DBMS_LOB.LOBMAXSIZE,
                                dest_offset    => l_dest_offset,
                                src_offset     => l_source_offset,
                                blob_csid      => 0,
                                lang_context   => l_lang_context,
                                warning        => l_warning);
        RETURN l_clob;
    END;


    PROCEDURE HANDLE_DNET_CONNECTION (p_session_id     VARCHAR2,
                                      p_absolute_url   VARCHAR2)
    IS
    BEGIN
        --raise_application_error(-20000, 'p_session_id='||p_session_id);
        --DBMS_SESSION.RESET_PACKAGE;
        EXECUTE IMMEDIATE 'ALTER SESSION SET cell_offload_processing=FALSE';

        uss_rpt_context.SetDnetRptContext (p_session_id);
        DBMS_SESSION.set_identifier (p_absolute_url);
    END;

    FUNCTION GetHistSession (p_hs_wu histsession.hs_wu%TYPE:= NULL)
        RETURN histsession.hs_id%TYPE
    IS
        l_hs   histsession.hs_id%TYPE;
    BEGIN
        INSERT INTO histsession (hs_id, hs_wu, hs_dt)
             VALUES (
                        0,
                        NVL (
                            p_hs_wu,
                            uss_rpt_context.GetContext (uss_rpt_context.gUID)),
                        SYSDATE)
          RETURNING hs_id
               INTO l_hs;

        RETURN l_hs;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                'TOOLS.GetHistSession: ' || CHR (10) || SQLERRM);
    END;

    FUNCTION GetCurrOrg
        RETURN NUMBER
    IS
    BEGIN
        RETURN TO_NUMBER (USS_RPT_CONTEXT.GetContext ('opfu'));
    END;


    FUNCTION GetCurrOrgTo
        RETURN NUMBER
    IS
        l_org_to   NUMBER;
    BEGIN
        SELECT MAX (org_to)
          INTO l_org_to
          FROM v_opfu
         WHERE org_id = TO_NUMBER (USS_RPT_CONTEXT.GetContext ('opfu'));

        RETURN l_org_to;
    END;
BEGIN
    NULL;
END TOOLS;
/