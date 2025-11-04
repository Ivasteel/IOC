/* Formatted on 8/12/2025 6:10:44 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_RBM.TOOLS
IS
    -- Author  : VANO
    -- Created : 11.10.2013 17:22:56
    -- Purpose : Ð³çí³ ñëóæáîâ³ ôóíêö³¿

    SUBTYPE t_lockhandler IS VARCHAR2 (100);

    gINSTANCE_LOCK_NAME   VARCHAR2 (100);

    FUNCTION ConvertC2BUTF8 (p_src CLOB)
        RETURN BLOB;

    FUNCTION ConvertC2B (p_src CLOB)
        RETURN BLOB;

    FUNCTION ConvertB2C (p_src BLOB)
        RETURN CLOB;

    FUNCTION PasteClob (p_dest CLOB, p_ins_data CLOB, p_signature VARCHAR2)
        RETURN CLOB;

    FUNCTION PasteBlob (p_dest BLOB, p_ins_data BLOB, p_signature VARCHAR2)
        RETURN BLOB;

    FUNCTION CRLF
        RETURN VARCHAR2;

    --Ôóíêö³ÿ êîäóâàííÿ â BASE64 (íàïðèêëàä äëÿ ïîäàëüøîãî âêëàäåííÿ â EML-ôîðìàò ÿê attachment)
    FUNCTION ConvertBlobToBase64 (p_in_data       IN BLOB,
                                  p_need_carret      INTEGER := 1)
        RETURN CLOB;

    FUNCTION ConvertClobToBase64 (p_clob CLOB)
        RETURN CLOB;

    FUNCTION ConvertClobFromBase64 (p_clob CLOB)
        RETURN CLOB;

    FUNCTION encode_base64 (p_blob_in IN BLOB)
        RETURN CLOB;

    FUNCTION decode_base64 (p_clob_in IN CLOB)
        RETURN BLOB;

    FUNCTION decode_base64_utf8 (p_clob_in IN CLOB)
        RETURN BLOB;

    FUNCTION b64_encode (p_clob CLOB, p_encoding IN VARCHAR2 DEFAULT NULL)
        RETURN CLOB;

    FUNCTION b64_decode (p_clob CLOB, p_encoding IN VARCHAR2 DEFAULT NULL)
        RETURN CLOB;

    PROCEDURE Request_Lock (
        p_permanent_name          VARCHAR2,
        p_var_name                VARCHAR2,
        p_errmessage              VARCHAR2,
        p_lockhandler         OUT t_lockhandler,
        p_lockmode                INTEGER DEFAULT DBMS_LOCK.x_mode,
        p_timeout                 INTEGER DEFAULT DBMS_LOCK.maxwait,
        p_release_on_commit       BOOLEAN DEFAULT FALSE);

    PROCEDURE Release_Lock (p_lockhandler t_lockhandler);

    PROCEDURE RequestDBLock (
        p_name                       VARCHAR2,
        p_lockhandler            OUT t_lockhandler,
        p_release_on_commit   IN     BOOLEAN DEFAULT FALSE);

    PROCEDURE Sleep (p_sec NUMBER);

    FUNCTION get_clob_substr (p_clob CLOB, p_start NUMBER, p_stop NUMBER)
        RETURN CLOB;

    -- Âèð³çàºìî çíà÷åííÿ àòðèáóòà â ³íøèé êëîá
    FUNCTION get_xmlattr_clob (p_xml_clob   CLOB,
                               p_attr       VARCHAR2,
                               p_nth        NUMBER:= 1)
        RETURN CLOB;

    -- Âèçíà÷àºìî ïðîêñ³ äëÿ js-ìîäóëÿ êðèïòîïåðåòâîðåíü ÷åðåç ïàðàìåòð â ÁÄ
    FUNCTION get_proxy
        RETURN VARCHAR2;

    FUNCTION utf8todeflang (p_clob IN CLOB)
        RETURN CLOB;

    FUNCTION hash_md5 (p_blob BLOB)
        RETURN VARCHAR2;

    FUNCTION GetHistSession (p_hs_wu histsession.hs_wu%TYPE:= NULL)
        RETURN histsession.hs_id%TYPE;

    FUNCTION GetHistSessionCmes (p_hs_cu histsession.hs_cu%TYPE:= NULL)
        RETURN histsession.hs_id%TYPE;

    FUNCTION GetOrgSName (p_org_id NUMBER)
        RETURN VARCHAR2;

    PROCEDURE HANDLE_DNET_CONNECTION (p_session_id     VARCHAR2,
                                      p_absolute_url   VARCHAR2);

    PROCEDURE WriteMsg (P_SOURCE VARCHAR2, p_message VARCHAR2 DEFAULT NULL);

    PROCEDURE Split_Pib (p_Pib   IN     VARCHAR2,
                         p_Ln       OUT VARCHAR2,
                         p_Fn       OUT VARCHAR2,
                         p_Mn       OUT VARCHAR2);

    FUNCTION GetHsUserPib (p_hs_id IN NUMBER)
        RETURN VARCHAR2;

    FUNCTION GetCmesOwnerCode (p_Cmes_Id         IN NUMBER,
                               p_Cmes_Owner_Id   IN NUMBER)
        RETURN VARCHAR2;

    FUNCTION GetCurrentCu
        RETURN NUMBER;

    FUNCTION GetCuPib (p_Cu_Id IN NUMBER)
        RETURN VARCHAR2;

    FUNCTION GetCuSc (p_Cu_Id IN NUMBER)
        RETURN NUMBER;

    FUNCTION GetCurrOrg
        RETURN NUMBER;

    FUNCTION GetCurrOrgName
        RETURN VARCHAR2;

    FUNCTION GetCurrOrgTo
        RETURN NUMBER;

    FUNCTION GetCurrLogin
        RETURN VARCHAR2;

    FUNCTION Check_User_Exists (p_wu_id ikis_sysweb.v$all_users.wu_id%TYPE)
        RETURN NUMBER;
END TOOLS;
/


GRANT EXECUTE ON IKIS_RBM.TOOLS TO DNET_PROXY
/

GRANT EXECUTE ON IKIS_RBM.TOOLS TO II01RC_RBMWEB_COMMON
/

GRANT EXECUTE ON IKIS_RBM.TOOLS TO II01RC_RBM_INTERNAL
/

GRANT EXECUTE ON IKIS_RBM.TOOLS TO OKOMISAROV
/

GRANT EXECUTE ON IKIS_RBM.TOOLS TO PORTAL_PROXY
/

GRANT EXECUTE ON IKIS_RBM.TOOLS TO SHOST
/

GRANT EXECUTE ON IKIS_RBM.TOOLS TO USS_DOC
/

GRANT EXECUTE ON IKIS_RBM.TOOLS TO USS_ESR
/

GRANT EXECUTE ON IKIS_RBM.TOOLS TO USS_PERSON
/

GRANT EXECUTE ON IKIS_RBM.TOOLS TO USS_RNSP
/

GRANT EXECUTE ON IKIS_RBM.TOOLS TO USS_VISIT
/


/* Formatted on 8/12/2025 6:10:51 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_RBM.TOOLS
IS
    FUNCTION ConvertC2BUTF8 (p_src CLOB)
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
                                NLS_CHARSET_ID ('UTF8'),
                                l_lang_context,
                                l_convert_warn);

        RETURN l_result;
    END;

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
                DBMS_LOB.writeappend (l_result,
                                      LN - i,
                                      DBMS_LOB.SUBSTR (p_dest, LN - i, i));
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

    FUNCTION CRLF
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN CHR (13) || CHR (10);
    END;

    FUNCTION ConvertBlobToBase64 (p_in_data       IN BLOB,
                                  p_need_carret      INTEGER := 1)
        RETURN CLOB
    AS
        l_buf_size      INTEGER := 12288;
        l_buf           RAW (32767);
        l_length        INTEGER;
        l_loops         INTEGER;
        l_pos           INTEGER := 1;
        l_encoded_raw   RAW (32767);
        l_encoded_vc2   VARCHAR2 (32767);
        l_result        CLOB;
    BEGIN
        l_length := DBMS_LOB.getLength (p_in_data);

        IF l_length > l_buf_size
        THEN
            l_loops := ROUND ((l_length / l_buf_size) + 0.5);
        ELSE
            l_loops := 1;
        END IF;

        DBMS_LOB.createTemporary (l_result, TRUE);
        DBMS_LOB.OPEN (l_result, DBMS_LOB.LOB_ReadWrite);

        FOR i IN 1 .. l_loops
        LOOP
            IF l_pos > l_length
            THEN
                CONTINUE;
            END IF;

            DBMS_LOB.READ (p_in_data,
                           l_buf_size,
                           l_pos,
                           l_buf);
            l_encoded_raw := UTL_ENCODE.base64_encode (l_buf);
            l_encoded_vc2 := UTL_RAW.cast_to_varchar2 (l_encoded_raw);
            DBMS_LOB.writeAppend (l_result,
                                  LENGTH (l_encoded_vc2),
                                  l_encoded_vc2);
            l_pos := l_pos + l_buf_size;
        END LOOP;

        IF p_need_carret = 1
        THEN
            DBMS_LOB.writeAppend (l_result, 1, CHR (10));
        END IF;

        RETURN l_result;
    END;

    FUNCTION ConvertClobToBase64 (p_clob CLOB)
        RETURN CLOB
    IS
        l_clob     CLOB;
        l_len      NUMBER;
        l_pos      NUMBER := 1;
        l_buffer   VARCHAR2 (32767);
        l_amount   NUMBER := 32767;
    BEGIN
        l_len := DBMS_LOB.getlength (p_clob);
        DBMS_LOB.createtemporary (l_clob, TRUE);

        WHILE l_pos <= l_len
        LOOP
            DBMS_LOB.read (p_clob,
                           l_amount,
                           l_pos,
                           l_buffer);
            l_buffer :=
                UTL_ENCODE.text_encode (l_buffer,
                                        encoding   => UTL_ENCODE.base64);
            l_pos := l_pos + l_amount;
            DBMS_LOB.writeappend (l_clob, LENGTH (l_buffer), l_buffer);
        END LOOP;

        RETURN l_clob;
    END;

    FUNCTION ConvertClobFromBase64 (p_clob CLOB)
        RETURN CLOB
    IS
        l_clob     CLOB;
        l_len      NUMBER;
        l_pos      NUMBER := 1;
        l_buffer   VARCHAR2 (32767);
        l_amount   NUMBER := 32767;
    BEGIN
        l_len := DBMS_LOB.getlength (p_clob);
        DBMS_LOB.createtemporary (l_clob, TRUE);

        WHILE l_pos <= l_len
        LOOP
            DBMS_LOB.read (p_clob,
                           l_amount,
                           l_pos,
                           l_buffer);
            l_buffer :=
                UTL_ENCODE.text_decode (l_buffer,
                                        encoding   => UTL_ENCODE.base64);
            l_pos := l_pos + l_amount;
            DBMS_LOB.writeappend (l_clob, LENGTH (l_buffer), l_buffer);
        END LOOP;

        RETURN l_clob;
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

        /*  dbms_lob.createtemporary(v_clob, true);
          v_offset := 1;
          FOR I IN 1 .. ceil(dbms_lob.getlength(p_blob_in) / v_chunk_size) LOOP
            dbms_lob.read(p_blob_in, v_chunk_size, v_offset, v_buffer_raw);
            v_buffer_raw := utl_encode.base64_encode(v_buffer_raw);
            v_buffer_varchar := utl_raw.cast_to_varchar2(v_buffer_raw);
            dbms_lob.writeappend(v_clob, length(v_buffer_varchar), v_buffer_varchar);
            v_offset := v_offset + v_chunk_size;
        --    dbms_output.put_line(i||to_char(sysdate, '-MI:SS'));
          END LOOP;
          v_result := v_clob;
          dbms_lob.freetemporary(v_clob);*/
        v_result := b64_encode (ConvertB2C (p_blob_in));
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

        /*  dbms_lob.createtemporary(v_blob, true);
          v_offset := 1;
          FOR I IN 1 .. ceil(dbms_lob.getlength(p_clob_in) / v_buffer_size) LOOP
            dbms_lob.read(p_clob_in, v_buffer_size, v_offset, v_buffer_varchar);
            v_buffer_raw := utl_raw.cast_to_raw(v_buffer_varchar);
            v_buffer_raw := utl_encode.base64_decode(v_buffer_raw);
            dbms_lob.writeappend(v_blob, utl_raw.length(v_buffer_raw), v_buffer_raw);
            v_offset := v_offset + v_buffer_size;
          END LOOP;
          v_result := v_blob;
          dbms_lob.freetemporary(v_blob);*/
        v_result := ConvertC2B (b64_decode (p_clob_in));
        RETURN v_result;
    END decode_base64;

    FUNCTION decode_base64_utf8 (p_clob_in IN CLOB)
        RETURN BLOB
    IS
        v_result   BLOB;
    BEGIN
        IF p_clob_in IS NULL
        THEN
            RETURN NULL;
        END IF;

        v_result := ConvertC2BUTF8 (b64_decode (p_clob_in));
        RETURN v_result;
    END;

    FUNCTION b64_encode (p_clob CLOB, p_encoding IN VARCHAR2 DEFAULT NULL)
        RETURN CLOB
    IS
        l_clob     CLOB;
        l_len      NUMBER;
        l_pos      NUMBER := 1;
        l_buffer   VARCHAR2 (32767);
        l_amount   NUMBER := 21000;
    BEGIN
        l_len := DBMS_LOB.getlength (p_clob);
        DBMS_LOB.createtemporary (l_clob, TRUE);

        WHILE l_pos <= l_len
        LOOP
            DBMS_LOB.read (p_clob,
                           l_amount,
                           l_pos,
                           l_buffer);
            l_buffer :=
                UTL_ENCODE.text_encode (l_buffer,
                                        encode_charset   => p_encoding,
                                        encoding         => UTL_ENCODE.base64);
            l_pos := l_pos + l_amount;
            DBMS_LOB.writeappend (l_clob, LENGTH (l_buffer), l_buffer);
        END LOOP;

        RETURN REPLACE (l_clob, CHR (13) || CHR (10), '');
    --RETURN l_clob;
    END;

    FUNCTION b64_decode (p_clob CLOB, p_encoding IN VARCHAR2 DEFAULT NULL)
        RETURN CLOB
    IS
        l_clob     CLOB;
        l_len      NUMBER;
        l_pos      NUMBER := 1;
        l_buffer   VARCHAR2 (32767);
        l_amount   NUMBER := 32400;
    BEGIN
        l_len := DBMS_LOB.getlength (p_clob);
        DBMS_LOB.createtemporary (l_clob, TRUE);

        WHILE l_pos <= l_len
        LOOP
            DBMS_LOB.read (p_clob,
                           l_amount,
                           l_pos,
                           l_buffer);
            l_buffer :=
                UTL_ENCODE.text_decode (l_buffer,
                                        encode_charset   => p_encoding,
                                        encoding         => UTL_ENCODE.base64);
            l_pos := l_pos + l_amount;
            DBMS_LOB.writeappend (l_clob, LENGTH (l_buffer), l_buffer);
        END LOOP;

        RETURN l_clob;
    END;

    PROCEDURE Request_Lock (
        p_permanent_name          VARCHAR2,
        p_var_name                VARCHAR2,
        p_errmessage              VARCHAR2,
        p_lockhandler         OUT t_lockhandler,
        p_lockmode                INTEGER DEFAULT DBMS_LOCK.x_mode,
        p_timeout                 INTEGER DEFAULT DBMS_LOCK.maxwait,
        p_release_on_commit       BOOLEAN DEFAULT FALSE)
    IS
        PROCEDURE Alloc (p_name VARCHAR2, p_lock OUT VARCHAR2)
        IS
            PRAGMA AUTONOMOUS_TRANSACTION;
        BEGIN
            DBMS_LOCK.ALLOCATE_UNIQUE (p_name, p_lock);
            COMMIT;
        EXCEPTION
            WHEN OTHERS
            THEN
                ROLLBACK;
                RAISE;
        END;
    BEGIN
        Alloc (p_permanent_name || p_var_name, p_lockhandler);

        IF NOT (DBMS_LOCK.REQUEST (p_lockhandler,
                                   p_lockmode,
                                   p_timeout,
                                   p_release_on_commit) = 0)
        THEN
            raise_application_error (-20000, p_errmessage);
        END IF;
    END;

    PROCEDURE Release_Lock (p_lockhandler t_lockhandler)
    IS
        l_result   INTEGER;
        l_errm     VARCHAR2 (1000) := NULL;
    BEGIN
        l_result := DBMS_LOCK.Release (lockhandle => p_lockhandler);

        CASE l_result
            WHEN 3
            THEN
                l_errm := 'Parameter error';
            WHEN 4
            THEN
                l_errm := 'Do not own lock specified by id or lockhandle';
            WHEN 5
            THEN
                l_errm := 'Illegal lock handle';
            ELSE
                RETURN;
        END CASE;

        IF l_errm IS NOT NULL
        THEN
            raise_application_error (
                -20000,
                   'Çâ³ëüíåííÿ áëîêèðîâêè "'
                || p_lockhandler
                || '" çàâåðøåíî ç ïîìèëêîþ: '
                || l_errm);
        END IF;
    END;

    PROCEDURE RequestDBLock (
        p_name                       VARCHAR2,
        p_lockhandler            OUT t_lockhandler,
        p_release_on_commit   IN     BOOLEAN DEFAULT FALSE)
    IS
    BEGIN
        Request_Lock (gINSTANCE_LOCK_NAME,
                      p_name,
                      'Ðåñóðñ <' || p_name || '> çàéíÿòî!',
                      p_lockhandler,
                      DBMS_LOCK.x_mode,
                      1,
                      p_release_on_commit);
    END;

    PROCEDURE Sleep (p_sec NUMBER)
    IS
    BEGIN
        DBMS_LOCK.sleep (p_sec);
    END;

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
        l_part := 1;

        WHILE (p_start + (l_part - 1) * l_portion_size <                 /*=*/
                                                         p_stop)
        LOOP
            l_portion :=
                LEAST (l_portion_size,
                       p_stop - p_start - (l_part - 1) * l_portion_size);
            l_buff :=                             /*utl_raw.cast_to_varchar2*/
                (DBMS_LOB.SUBSTR (p_clob,
                                  l_portion,
                                  p_start + (l_part - 1) * l_portion_size));
            l_part := l_part + 1;
            DBMS_LOB.writeappend (l_new_clob,
                                  DBMS_LOB.getlength ((l_buff)), /*utl_raw.cast_to_raw*/
                                  (l_buff));
        END LOOP;

        RETURN l_new_clob;
    END;

    -- Âèð³çàºìî çíà÷åííÿ àòðèáóòà â ³íøèé êëîá
    FUNCTION get_xmlattr_clob (p_xml_clob   CLOB,
                               p_attr       VARCHAR2,
                               p_nth        NUMBER:= 1)
        RETURN CLOB
    IS
        l_part           NUMBER;
        l_portion        NUMBER;
        l_new_clob       CLOB;
        l_buff           CLOB;
        l_portion_size   NUMBER := 10000;
        l_stop           NUMBER;
        l_start          NUMBER;
    BEGIN
        DBMS_LOB.createtemporary (lob_loc => l_new_clob, CACHE => TRUE);
        DBMS_LOB.OPEN (lob_loc     => l_new_clob,
                       open_mode   => DBMS_LOB.lob_readwrite);
        l_start :=
              DBMS_LOB.INSTR (lob_loc   => p_xml_clob,
                              pattern   => '<' || p_attr || '>', /*offset => 1,*/
                              nth       => p_nth)
            + DBMS_LOB.getlength ('<' || p_attr || '>');
        l_stop :=
            DBMS_LOB.INSTR (lob_loc   => p_xml_clob,
                            pattern   => '</' || p_attr || '>', /*offset => 1,*/
                            nth       => p_nth)                       /* - 1*/
                                               ;
        l_new_clob := get_clob_substr (p_xml_clob, l_start, l_stop);
        RETURN l_new_clob;
    END;

    -- Âèçíà÷àºìî ïðîêñ³ äëÿ js-ìîäóëÿ êðèïòîïåðåòâîðåíü ÷åðåç ïàðàìåòð â ÁÄ
    FUNCTION get_proxy
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN IKIS_SYS.IKIS_COMMON.GetApptParam (p_name => 'IKS_RBM_PROXY');
    END;


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

    FUNCTION hash_md5 (p_blob BLOB)
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN sys.DBMS_CRYPTO.HASH (p_blob, 2                    /*HASH_MD5*/
                                              );
    END;

    FUNCTION GetHistSession (p_hs_wu histsession.hs_wu%TYPE:= NULL)
        RETURN histsession.hs_id%TYPE
    IS
        l_hs   histsession.hs_id%TYPE;
    BEGIN
        INSERT INTO histsession (hs_id, hs_wu, hs_dt)
             VALUES (0,
                     NVL (p_hs_wu, ikis_rbm_context.GetContext ('UID')),
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

    FUNCTION GetHistSessionCmes (p_hs_cu histsession.hs_cu%TYPE:= NULL)
        RETURN histsession.hs_id%TYPE
    IS
        l_hs   histsession.hs_id%TYPE;
    BEGIN
        INSERT INTO histsession (hs_id, hs_cu, hs_dt)
             VALUES (0,
                     NVL (p_hs_cu, cmes_context.Get_Context ('CUID')),
                     SYSDATE)
          RETURNING hs_id
               INTO l_hs;

        RETURN l_hs;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                'TOOLS.GetHistSessionCmes: ' || CHR (10) || SQLERRM);
    END;

    FUNCTION GetOrgSName (p_org_id NUMBER)
        RETURN VARCHAR2
    IS
        l_name   VARCHAR2 (1000);
    BEGIN
        SELECT REPLACE (
                   REPLACE (
                       REPLACE (
                           REPLACE (
                               REPLACE (
                                   REPLACE (
                                       REPLACE (
                                           REPLACE (
                                               REPLACE (
                                                   REPLACE (
                                                       REPLACE (
                                                           REPLACE (
                                                               REPLACE (
                                                                   REPLACE (
                                                                       REPLACE (
                                                                           REPLACE (
                                                                               REPLACE (
                                                                                   REPLACE (
                                                                                       REPLACE (
                                                                                           REPLACE (
                                                                                               REPLACE (
                                                                                                   REPLACE (
                                                                                                       REPLACE (
                                                                                                           UPPER (
                                                                                                               REPLACE (
                                                                                                                   org_name,
                                                                                                                   '  ',
                                                                                                                   ' ')),
                                                                                                           'ÑÒÐÓÊÒÓÐÍÈÉ Ï²ÄÐÎÇÄ²Ë ÂÈÊÎÍÀÂ×ÎÃÎ ÎÐÃÀÍÓ ',
                                                                                                           'ÑÏÂÎ '),
                                                                                                       'ÎÁËÀÑÍÎ¯ ÄÅÐÆÀÂÍÎ¯ ÀÄÌ²Í²ÑÒÐÀÖ²¯ ',
                                                                                                       ' ÎÄÀ'),
                                                                                                   ' ÎÁËÀÑÍÎ¯ ÄÅÐÆÀÂÍÎ¯ ÀÄÌ²Í²ÑÒÐÀÖ²¯',
                                                                                                   ' ÎÄÀ'),
                                                                                               'ÓÏÐÀÂË²ÍÍß ÑÎÖ²ÀËÜÍÎÃÎ ÐÎÇÂÈÒÊÓ ',
                                                                                               'ÓÑÐ '),
                                                                                           'ÄÅÏÀÐÒÀÌÅÍÒ ÑÎÖÏÎË²ÒÈÊÈ ',
                                                                                           'ÄÑÏ '),
                                                                                       'ÓÏÐÀÂË²ÍÍß ÑÎÖ²ÀËÜÍÎ¯ ÏÎË²ÒÈÊÈ ',
                                                                                       'ÓÑÏ '),
                                                                                   'ÄÅÏÀÐÒÀÌÅÍÒ ÑÎÖ²ÀËÜÍÎ¯ ÒÀ ÌÎËÎÄ²ÆÍÎ¯ ÏÎË²ÒÈÊÈ ',
                                                                                   'ÄÑÌÏ '),
                                                                               'ÄÅÏÀÐÒÀÌÅÍÒ ÏÐÀÖ² ÒÀ ÑÎÖ²ÀËÜÍÎ¯ ÏÎË²ÒÈÊÈ ',
                                                                               'ÄÏÑÏ '),
                                                                           'ÎÁËÀÑÍÈÉ ÖÅÍÒÐ ÏÎ ÍÀÐÀÕÓÂÀÍÍÞ ÒÀ ÇÄ²ÉÑÍÅÍÍÞ ÑÎÖ²ÀËÜÍÈÕ ÂÈÏËÀÒ',
                                                                           'ÎÖÍÇÑÂ'),
                                                                       'ÄÅÏÀÐÒÀÌÅÍÒ ÑÎÖ²ÀËÜÍÎ¯ ÏÎË²ÒÈÊÈ ',
                                                                       'ÄÑÏ '),
                                                                   'ÄÅÏÀÐÒÀÌÅÍÒ ÑÎÖ²ÀËÜÍÎ¯ ÒÀ Ñ²ÌÅÉÍÎ¯ ÏÎË²ÒÈÊÈ ',
                                                                   'ÄÑÑÏ '),
                                                               'ÄÅÏÀÐÒÀÌÅÍÒ ÏÐÀÖ² ÒÀ ÑÎÖ²ÀËÜÍÎÃÎ ÇÀÕÈÑÒÓ ÍÀÑÅËÅÍÍß ',
                                                               'ÄÏÑÇÍ '),
                                                           'ÂÈÊÎÍÀÂ×ÎÃÎ ÊÎÌ²ÒÅÒÓ ',
                                                           'ÂÊ '),
                                                       'ÎÁ''ªÄÍÀÍÀ ÒÅÐÈÒÎÐ²ÀËÜÍÀ ÃÐÎÌÀÄÀ',
                                                       'ÎÒÃ'),
                                                   'ÑÅËÈÙÍÀ ÒÅÐÈÒÎÐ²ÀËÜÍÀ ÃÐÎÌÀÄÀ',
                                                   'ÑÒÃ'),
                                               'Ì²ÑÜÊÀ ÒÅÐÈÒÎÐ²ÀËÜÍÀ ÃÐÎÌÀÄÀ',
                                               'ÌÒÃ'),
                                           'Ñ²ËÜÑÜÊÀ ÒÅÐÈÒÎÐ²ÀËÜÍÀ ÃÐÎÌÀÄÀ',
                                           'ÑÒÃ'),
                                       'ÓÏÐÀÂË²ÍÍß ÑÎÖ²ÀËÜÍÎÃÎ ÇÀÕÈÑÒÓ ÍÀÑÅËÅÍÍß ',
                                       'ÓÑÇÍ '),
                                   'ÓÏÐÀÂË²ÍÍß ÑÎÖ²ÀËÜÍÎÃÎ ÇÀÕÈÑÒÓ ',
                                   'ÓÑÇ '),
                               'ÄÅÏÀÐÒÀÌÅÍÒ ÑÎÖ²ÀËÜÍÎÃÎ ÇÀÕÈÑÒÓ ÍÀÑÅËÅÍÍß ÒÀ ÏÈÒÀÍÜ ÀÒÎ ',
                               'ÄÑÇÍ ÒÀ ÏÀÒÎ '),
                           'ÄÅÏÀÐÒÀÌÅÍÒ ÑÎÖ²ÀËÜÍÎÃÎ ÇÀÕÈÑÒÓ ÍÀÑÅËÅÍÍß ',
                           'ÄÑÇÍ '),
                       'Ì²ÑÜÊÎ¯ ÐÀÄÈ',
                       'ÌÐ'),
                   'Ì²ÑÜÊÎ¯ ÄÅÐÆÀÂÍÎ¯ ÀÄÌ²Í²ÑÒÐÀÖ²¯',
                   'ÌÄÀ')
          INTO l_name
          FROM v_opfu t
         WHERE 1 = 1 AND org_id = p_org_id;

        RETURN l_name;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN NULL;
    END;

    PROCEDURE HANDLE_DNET_CONNECTION (p_session_id     VARCHAR2,
                                      p_absolute_url   VARCHAR2)
    IS
    BEGIN
        --DBMS_SESSION.RESET_PACKAGE;
        EXECUTE IMMEDIATE 'ALTER SESSION SET cell_offload_processing=FALSE';

        ikis_rbm_context.SetDnetRbmContext (p_session_id);
        DBMS_SESSION.set_identifier (p_absolute_url);
    END;

    PROCEDURE WriteMsg (P_SOURCE VARCHAR2, p_message VARCHAR2 DEFAULT NULL)
    IS
    BEGIN
        IF p_message IS NULL
        THEN
            IKIS_SYS.IKIS_AUDIT.WriteMsg (
                p_msg_type   => 'USER_ACTIVITY',
                p_msg_text   =>
                       P_SOURCE
                    || '#'
                    || SYS_CONTEXT ('USERENV', 'CLIENT_IDENTIFIER'));
        ELSE
            IKIS_SYS.IKIS_AUDIT.WriteMsg (
                p_msg_type   => 'USER_ACTIVITY',
                p_msg_text   =>
                       P_SOURCE
                    || '#'
                    || SYS_CONTEXT ('USERENV', 'CLIENT_IDENTIFIER')
                    || '#'
                    || p_message);
        END IF;
    END;

    PROCEDURE Split_Pib (p_Pib   IN     VARCHAR2,
                         p_Ln       OUT VARCHAR2,
                         p_Fn       OUT VARCHAR2,
                         p_Mn       OUT VARCHAR2)
    IS
        l_Pib   VARCHAR2 (250);
    BEGIN
        l_Pib := p_Pib;

            SELECT UPPER (TRIM (MAX (CASE
                                         WHEN ROWNUM = 1
                                         THEN
                                             REGEXP_SUBSTR (l_Pib,
                                                            '[^ ]+',
                                                            1,
                                                            LEVEL)
                                     END))),
                   UPPER (TRIM (MAX (CASE
                                         WHEN ROWNUM = 2
                                         THEN
                                             REGEXP_SUBSTR (l_Pib,
                                                            '[^ ]+',
                                                            1,
                                                            LEVEL)
                                     END))),
                   UPPER (TRIM (MAX (CASE
                                         WHEN ROWNUM = 3
                                         THEN
                                             REGEXP_SUBSTR (l_Pib,
                                                            '[^ ]+',
                                                            1,
                                                            LEVEL)
                                     END)))
              INTO p_Ln, p_Fn, p_Mn
              FROM DUAL
        CONNECT BY REGEXP_SUBSTR (l_Pib,
                                  '[^ ]+',
                                  1,
                                  LEVEL)
                       IS NOT NULL;
    END;

    FUNCTION GetHsUserPib (p_hs_id IN NUMBER)
        RETURN VARCHAR2
    IS
        l_Name   VARCHAR2 (300);
        l_Wu     NUMBER;
        l_Cu     NUMBER;
    BEGIN
        IF p_Hs_Id IS NULL
        THEN
            RETURN NULL;
        END IF;

        SELECT s.Hs_Wu, s.Hs_Cu
          INTO l_Wu, l_Cu
          FROM Histsession s
         WHERE s.Hs_Id = p_Hs_Id;

        IF l_Wu IS NOT NULL
        THEN
            SELECT u.Wu_Pib
              INTO l_Name
              FROM Ikis_Sysweb.V$all_Users u
             WHERE u.Wu_Id = l_Wu;
        ELSIF l_Cu IS NOT NULL
        THEN
            SELECT u.Cu_Pib
              INTO l_Name
              FROM Cmes_Users u
             WHERE u.Cu_Id = l_Cu;
        END IF;

        RETURN l_Name;
    END;

    FUNCTION GetCmesOwnerCode (p_Cmes_Id         IN NUMBER,
                               p_Cmes_Owner_Id   IN NUMBER)
        RETURN VARCHAR2
    IS
        l_Result   VARCHAR2 (10);
    BEGIN
        SELECT o.Cmes_Owner_Code
          INTO l_Result
          FROM v_Cmes_Owners o
         WHERE o.Cmes_Owner_Id = p_Cmes_Owner_Id AND o.Cmes_Id = p_Cmes_Id;

        RETURN l_Result;
    END;

    ---------------------------------------------------------------------------
    --                 Îòðèìàííÿ ûäåíòèôûêàòîðó ïîòî÷íîãî êîðèñòóâà÷à
    ---------------------------------------------------------------------------
    FUNCTION GetCurrentCu
        RETURN NUMBER
    IS
    BEGIN
        RETURN Cmes_Context.Get_Context (Cmes_Context.g_Cuid);
    END;

    FUNCTION GetCuPib (p_Cu_Id IN NUMBER)
        RETURN VARCHAR2
    IS
        l_Cu_Pib   Cmes_Users.Cu_Pib%TYPE;
    BEGIN
        SELECT u.Cu_Pib
          INTO l_Cu_Pib
          FROM Cmes_Users u
         WHERE u.Cu_Id = p_Cu_Id;

        RETURN l_Cu_Pib;
    END;

    FUNCTION GetCuSc (p_Cu_Id IN NUMBER)
        RETURN NUMBER
    IS
        l_Sc_Id   NUMBER;
    BEGIN
        SELECT MAX (r.Cu2r_Cmes_Owner_Id)
          INTO l_Sc_Id
          FROM Cu_Users2roles r
         WHERE     r.Cu2r_Cu = p_Cu_Id
               AND r.History_Status = 'A'
               AND r.Cu2r_Cr = 1;

        RETURN l_Sc_Id;
    END;


    FUNCTION GetCurrOrg
        RETURN NUMBER
    IS
    BEGIN
        RETURN TO_NUMBER (
                   ikis_rbm_context.GetContext (ikis_rbm_context.gOPFU));
    END;

    FUNCTION GetCurrOrgName
        RETURN VARCHAR2
    IS
        l_name   VARCHAR2 (1000);
        l_org    NUMBER
            := TO_NUMBER (
                   ikis_rbm_context.GetContext (ikis_rbm_context.gOPFU));
    BEGIN
        SELECT org_name
          INTO l_name
          FROM v_opfu
         WHERE org_id = l_org;

        RETURN l_name;
    END;

    FUNCTION GetCurrOrgTo
        RETURN NUMBER
    IS
        l_org_to   NUMBER;
        l_org      NUMBER
            := TO_NUMBER (
                   ikis_rbm_context.GetContext (ikis_rbm_context.gOPFU));
    BEGIN
        SELECT MAX (org_to)
          INTO l_org_to
          FROM v_opfu
         WHERE org_id = l_org;

        RETURN l_org_to;
    END;

    FUNCTION GetCurrLogin
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN IKIS_RBM_CONTEXT.GetContext (IKIS_RBM_CONTEXT.gLogin);
    END;

    FUNCTION Check_User_Exists (p_wu_id ikis_sysweb.v$all_users.wu_id%TYPE)
        RETURN NUMBER
    IS
        l_Result   NUMBER;
    BEGIN
        SELECT COUNT (1)
          INTO l_Result
          FROM ikis_sysweb.v$all_users wu
         WHERE wu.wu_id = p_wu_id;

        RETURN l_Result;
    END;
BEGIN
    gINSTANCE_LOCK_NAME := 'IKIS_RBM';
END TOOLS;
/