/* Formatted on 8/12/2025 5:55:27 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_NDI.TOOLS
IS
    -- Author  : VANO
    -- Created : 11.02.2021 18:40:37
    -- Purpose : Допоміжні функції

    gINSTANCE_LOCK_NAME   VARCHAR2 (100);

    SUBTYPE t_lockhandler IS VARCHAR2 (100);

    SUBTYPE t_msg IS VARCHAR2 (4000);

    FUNCTION request_lock (p_descr IN VARCHAR2)
        RETURN t_lockhandler;

    FUNCTION request_lock (p_descr               IN VARCHAR2,
                           p_error_msg           IN VARCHAR2,
                           p_release_on_commit   IN BOOLEAN DEFAULT TRUE)
        RETURN t_lockhandler;

    PROCEDURE release_lock (p_lock_handler IN t_lockhandler);

    PROCEDURE Sleep (p_sec NUMBER);

    FUNCTION GetCurrOrg
        RETURN NUMBER;

    FUNCTION GetCurrOrgTo
        RETURN NUMBER;

    FUNCTION GetCurrOrgName
        RETURN VARCHAR2;

    FUNCTION GetCurrWu
        RETURN NUMBER;

    FUNCTION GetCurrLogin
        RETURN VARCHAR2;

    FUNCTION GetCurrUserPIB (P_MODE IN NUMBER DEFAULT 0)
        RETURN VARCHAR2;

    FUNCTION GetUserLogin (P_WU_ID IN NUMBER)
        RETURN VARCHAR2;

    FUNCTION GetCurrUserWutCode
        RETURN VARCHAR2;

    FUNCTION GetUserPib (P_WU_ID IN NUMBER)
        RETURN VARCHAR2;

    FUNCTION get_last_pay_order_num (p_id IN NUMBER)
        RETURN NUMBER;

    FUNCTION GetHistSession
        RETURN histsession.hs_id%TYPE;

    FUNCTION GetHistSessionA
        RETURN histsession.hs_id%TYPE;

    FUNCTION Decode_Dict (
        p_Nddc_Tp         IN Ndi_Decoding_Config.Nddc_Tp%TYPE,
        p_Nddc_Src        IN Ndi_Decoding_Config.Nddc_Src%TYPE,
        p_Nddc_Dest       IN Ndi_Decoding_Config.Nddc_Dest%TYPE,
        p_Nddc_Code_Src   IN Ndi_Decoding_Config.Nddc_Code_Src%TYPE)
        RETURN Ndi_Decoding_Config.Nddc_Code_Dest%TYPE;

    FUNCTION Decode_Dict_Reverse (
        p_Nddc_Tp          IN Ndi_Decoding_Config.Nddc_Tp%TYPE,
        p_Nddc_Src         IN Ndi_Decoding_Config.Nddc_Src%TYPE,
        p_Nddc_Dest        IN Ndi_Decoding_Config.Nddc_Dest%TYPE,
        p_Nddc_Code_Dest   IN Ndi_Decoding_Config.Nddc_Code_Dest%TYPE)
        RETURN Ndi_Decoding_Config.Nddc_Code_Src%TYPE;


    FUNCTION check_user (p_mode INTEGER)
        RETURN BOOLEAN;

    PROCEDURE check_user_and_raise (p_mode INTEGER);

    FUNCTION b64_encode (p_clob CLOB)
        RETURN CLOB;

    FUNCTION b64_decode (p_clob CLOB)
        RETURN CLOB;

    FUNCTION ConvertC2B (p_src CLOB)
        RETURN BLOB;

    FUNCTION ConvertB2C (p_src BLOB)
        RETURN CLOB;

    FUNCTION encode_base64 (p_blob_in IN BLOB)
        RETURN CLOB;

    FUNCTION decode_base64 (p_clob_in IN CLOB)
        RETURN BLOB;

    FUNCTION utf8todeflang (p_clob IN CLOB)
        RETURN CLOB;

    FUNCTION GetKOATFullName (p_koat_id IN NUMBER)
        RETURN VARCHAR2;

    PROCEDURE validate_param (p_val VARCHAR2);

    FUNCTION Check_Dict_Value (p_Value IN VARCHAR2, p_Dict IN VARCHAR2)
        RETURN NUMBER;

    PROCEDURE Check_Dict_Value (p_Value IN VARCHAR2, p_Dict IN VARCHAR2);

    --Отримання типу інстансу бази
    FUNCTION get_inctance_type
        RETURN VARCHAR2;

    --Визначення можливості редагування запису
    FUNCTION can_edit_record (p_record_src VARCHAR2)
        RETURN VARCHAR2;

    --Визанчення джерела записів довідників
    FUNCTION get_record_src
        RETURN VARCHAR2;

    --Визанчення можливості зміни записів
    PROCEDURE check_record_src (p_record_src VARCHAR2);
END TOOLS;
/


GRANT EXECUTE ON USS_NDI.TOOLS TO II01RC_USS_NDI_INTERNAL
/

GRANT EXECUTE ON USS_NDI.TOOLS TO IKIS_RBM
/

GRANT EXECUTE ON USS_NDI.TOOLS TO USS_ESR
/

GRANT EXECUTE ON USS_NDI.TOOLS TO USS_PERSON
/

GRANT EXECUTE ON USS_NDI.TOOLS TO USS_RNSP
/

GRANT EXECUTE ON USS_NDI.TOOLS TO USS_RPT
/

GRANT EXECUTE ON USS_NDI.TOOLS TO USS_VISIT
/


/* Formatted on 8/12/2025 5:55:33 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_NDI.TOOLS
IS
    g_instance_type   VARCHAR (250) := NULL;

    FUNCTION request_lock (p_descr IN VARCHAR2)
        RETURN t_lockhandler
    IS
        l_lock_handler   t_lockhandler;
    BEGIN
        ikis_sys.ikis_lock.request_lock (
            p_permanent_name      => gINSTANCE_LOCK_NAME,
            p_var_name            => p_descr,
            p_errmessage          => 'BUSY',
            p_lockhandler         => l_lock_handler,
            p_timeout             => 0,
            p_release_on_commit   => TRUE);

        RETURN l_lock_handler;
    END request_lock;

    FUNCTION request_lock (p_descr               IN VARCHAR2,
                           p_error_msg           IN VARCHAR2,
                           p_release_on_commit   IN BOOLEAN DEFAULT TRUE)
        RETURN t_lockhandler
    IS
        l_lock_handler   t_lockhandler;
    BEGIN
        ikis_sys.ikis_lock.request_lock (
            p_permanent_name      => gINSTANCE_LOCK_NAME,
            p_var_name            => p_descr,
            p_errmessage          => p_error_msg,
            p_lockhandler         => l_lock_handler,
            p_timeout             => 0,
            p_release_on_commit   => p_release_on_commit);

        RETURN l_lock_handler;
    END request_lock;

    PROCEDURE release_lock (p_lock_handler IN t_lockhandler)
    IS
    BEGIN
        IF p_lock_handler IS NOT NULL
        THEN
            ikis_sys.ikis_lock.releace_lock (p_lock_handler);
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            NULL;
    END release_lock;

    PROCEDURE Sleep (p_sec NUMBER)
    IS
    BEGIN
        IKIS_LOCK.sleep (p_sec);
    END;

    FUNCTION GetCurrOrg
        RETURN NUMBER
    IS
    BEGIN
        RETURN TO_NUMBER (SYS_CONTEXT ('USS_ESR', 'ORG'));
    END;


    FUNCTION GetCurrOrgTo
        RETURN NUMBER
    IS
        l_org_to   NUMBER;
    BEGIN
        SELECT MAX (org_to)
          INTO l_org_to
          FROM v_opfu
         WHERE org_id = TO_NUMBER (SYS_CONTEXT ('USS_ESR', 'ORG'));

        RETURN l_org_to;
    END;

    FUNCTION GetCurrOrgName
        RETURN VARCHAR2
    IS
        l_name   VARCHAR2 (1000);
    BEGIN
        SELECT org_name
          INTO l_name
          FROM v_opfu
         WHERE org_id = GetCurrOrg;

        RETURN l_name;
    END;

    FUNCTION GetCurrWu
        RETURN NUMBER
    IS
    BEGIN
        RETURN TO_NUMBER (SYS_CONTEXT ('USS_ESR', 'USSUID'));
    END;

    FUNCTION GetCurrLogin
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN SYS_CONTEXT ('USS_ESR', 'LOGIN');
    END;

    FUNCTION GetCurrUserWutCode
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN SYS_CONTEXT ('USS_ESR', 'IUTPCODE');
    END;

    FUNCTION GetCurrUserPIB (P_MODE IN NUMBER DEFAULT 0)
        RETURN VARCHAR2
    IS
        l_pib       VARCHAR2 (250);
        l_curr_wu   NUMBER;
    BEGIN
        l_curr_wu := GetCurrWu;

        SELECT wu_pib
          INTO l_pib
          FROM ikis_sysweb.V$ALL_USERS
         WHERE wu_id = l_curr_wu;

        RETURN l_pib;
    END;


    FUNCTION GetUserLogin (P_WU_ID IN NUMBER)
        RETURN VARCHAR2
    IS
        l_login   VARCHAR2 (250);
    BEGIN
        SELECT wu_login
          INTO l_login
          FROM ikis_sysweb.V$ALL_USERS
         WHERE wu_id = P_WU_ID;

        RETURN l_login;
    END;

    FUNCTION GetUserPib (P_WU_ID IN NUMBER)
        RETURN VARCHAR2
    IS
        l_pib   VARCHAR2 (250);
    BEGIN
        SELECT wu_pib
          INTO l_pib
          FROM ikis_sysweb.V$ALL_USERS
         WHERE wu_id = P_WU_ID;

        RETURN l_pib;
    END;

    FUNCTION get_last_pay_order_num (p_id IN NUMBER)
        RETURN NUMBER
    IS
        l_res   NUMBER;
        l_hs    histsession.hs_id%TYPE;
    BEGIN
        SELECT NVL (t.dppa_last_payment_order, 0) + 1
          INTO l_res
          FROM uss_ndi.v_ndi_pay_person_acc t
         WHERE t.dppa_id = p_id;

        l_hs := Tools.GetHistSession;

        UPDATE uss_ndi.v_ndi_pay_person_acc t
           SET t.dppa_last_payment_order = l_res, dppa_hs_upd = l_hs
         WHERE t.dppa_id = p_id;

        RETURN l_res;
    END;

    FUNCTION GetHistSession
        RETURN histsession.hs_id%TYPE
    IS
        l_hs   histsession.hs_id%TYPE;
    BEGIN
        INSERT INTO histsession (hs_id, hs_wu, hs_dt)
             VALUES (0, SYS_CONTEXT ('IKISWEBADM', 'IKISUID'), SYSDATE)
          RETURNING hs_id
               INTO l_hs;

        RETURN l_hs;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                'uss_ndi.TOOLS.GetHistSession: ' || CHR (10) || SQLERRM);
    END;

    FUNCTION GetHistSessionA
        RETURN histsession.hs_id%TYPE
    IS
        PRAGMA AUTONOMOUS_TRANSACTION;

        l_hs   histsession.hs_id%TYPE;
    BEGIN
        l_hs := GetHistSession;

        COMMIT;

        RETURN l_hs;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                'uss_ndi.TOOLS.GetHistSession: ' || CHR (10) || SQLERRM);
    END;

    FUNCTION Decode_Dict (
        p_Nddc_Tp         IN Ndi_Decoding_Config.Nddc_Tp%TYPE,
        p_Nddc_Src        IN Ndi_Decoding_Config.Nddc_Src%TYPE,
        p_Nddc_Dest       IN Ndi_Decoding_Config.Nddc_Dest%TYPE,
        p_Nddc_Code_Src   IN Ndi_Decoding_Config.Nddc_Code_Src%TYPE)
        RETURN Ndi_Decoding_Config.Nddc_Code_Dest%TYPE
    IS
        l_Result   Ndi_Decoding_Config.Nddc_Code_Dest%TYPE;
    BEGIN
        SELECT MAX (c.Nddc_Code_Dest)
          INTO l_Result
          FROM Ndi_Decoding_Config c
         WHERE     c.Nddc_Tp = p_Nddc_Tp
               AND c.Nddc_Src = p_Nddc_Src
               AND c.Nddc_Dest = p_Nddc_Dest
               AND c.Nddc_Code_Src = p_Nddc_Code_Src;

        RETURN l_Result;
    END;

    FUNCTION Decode_Dict_Reverse (
        p_Nddc_Tp          IN Ndi_Decoding_Config.Nddc_Tp%TYPE,
        p_Nddc_Src         IN Ndi_Decoding_Config.Nddc_Src%TYPE,
        p_Nddc_Dest        IN Ndi_Decoding_Config.Nddc_Dest%TYPE,
        p_Nddc_Code_Dest   IN Ndi_Decoding_Config.Nddc_Code_Dest%TYPE)
        RETURN Ndi_Decoding_Config.Nddc_Code_Src%TYPE
    IS
        l_Result   Ndi_Decoding_Config.Nddc_Code_Src%TYPE;
    BEGIN
        SELECT MAX (c.Nddc_Code_Src)
          INTO l_Result
          FROM Ndi_Decoding_Config c
         WHERE     c.Nddc_Tp = p_Nddc_Tp
               AND c.Nddc_Src = p_Nddc_Src
               AND c.Nddc_Dest = p_Nddc_Dest
               AND c.Nddc_Code_Dest = p_Nddc_Code_Dest;

        RETURN l_Result;
    END;

    FUNCTION check_user (p_mode INTEGER)
        RETURN BOOLEAN
    IS
        l_wut_code   VARCHAR2 (10);
    BEGIN
        IF p_mode = 1
        THEN                     --Наявність ролі W_ESR_NDI для користувача ЦА
            l_wut_code := GetCurrUserWutCode;
            RETURN     l_wut_code = 'UMC'
                   AND is_role_assigned (GetCurrLogin,
                                         'W_ESR_NDI',
                                         l_wut_code);
        ELSIF p_mode = 2
        THEN --Наявність ролі W_ESR_NDI для користувача ЦА, ДСЗН, ОСЗН, Ценру виплат
            l_wut_code := GetCurrUserWutCode;
            RETURN     l_wut_code IN ('UMC',
                                      'UMR',
                                      'UMD',
                                      'UMV')
                   AND is_role_assigned (GetCurrLogin,
                                         'W_ESR_NDI',
                                         l_wut_code);
        ELSIF p_mode = 3
        THEN --Наявність ролі W_ESR_NDI (для користувача ЦА, ДСЗН, ОСЗН, Ценру виплат, ІОЦ) або W_ESR_KPAYROLL або W_ESR_BUDGET_INSP
            l_wut_code := GetCurrUserWutCode;
            RETURN        l_wut_code IN ('UMC',
                                         'UMR',
                                         'UMD',
                                         'UMV',
                                         'UOC')
                      AND is_role_assigned (GetCurrLogin,
                                            'W_ESR_NDI',
                                            l_wut_code)
                   OR is_role_assigned (GetCurrLogin,
                                        'W_ESR_KPAYROLL',
                                        l_wut_code)
                   OR is_role_assigned (GetCurrLogin,
                                        'W_ESR_BUDGET_INSP',
                                        l_wut_code);
        ELSIF p_mode = 4
        THEN    --Наявність ролі W_ESR_NDI для користувача ЦА, ДСЗН, ОСЗН, ІОЦ
            l_wut_code := GetCurrUserWutCode;
            RETURN     l_wut_code IN ('UMC',
                                      'UMR',
                                      'UMD',
                                      'UOC')
                   AND is_role_assigned (GetCurrLogin,
                                         'W_ESR_NDI',
                                         l_wut_code);
        ELSIF p_mode = 5
        THEN --Наявність ролі W_ESR_NDI для користувача ЦА, ДСЗН, ОСЗН, Ценру виплат, ІОЦ
            l_wut_code := GetCurrUserWutCode;
            RETURN     l_wut_code IN ('UMC',
                                      'UMR',
                                      'UMD',
                                      'UMV',
                                      'UOC')
                   AND is_role_assigned (GetCurrLogin,
                                         'W_ESR_NDI',
                                         l_wut_code);
        ELSIF p_mode = 6
        THEN                       --Наявність ролі W_ESR_NDI || W_ESR_PAYROLL
            l_wut_code := GetCurrUserWutCode;
            RETURN    is_role_assigned (GetCurrLogin,
                                        'W_ESR_NDI',
                                        l_wut_code)
                   OR is_role_assigned (GetCurrLogin,
                                        'W_ESR_PAYROLL',
                                        l_wut_code);
        ELSIF p_mode = 7
        THEN                --Наявність ролі W_ESR_NDI для користувача ЦА, ІОЦ
            l_wut_code := GetCurrUserWutCode;
            RETURN     l_wut_code IN ('UMC', 'UOC')
                   AND is_role_assigned (GetCurrLogin,
                                         'W_ESR_NDI',
                                         l_wut_code);
        ELSIF p_mode = 8
        THEN --Наявність ролі W_ESR_NDI для користувача ЦА, ДСЗН, ОСЗН, Ценру виплат, ІОЦ
            l_wut_code := GetCurrUserWutCode;
            RETURN        l_wut_code IN ('UMC',
                                         'UMR',
                                         'UMD',
                                         'UMV',
                                         'UOC')
                      AND is_role_assigned (GetCurrLogin,
                                            'W_ESR_NDI',
                                            l_wut_code)
                   OR l_wut_code IN ('UMD', 'UMV');
        ELSIF p_mode = 9
        THEN     --Наявність ролі W_ESR_NDI для користувача ОСЗН, Ценру виплат
            l_wut_code := GetCurrUserWutCode;
            RETURN     l_wut_code IN ('UMD', 'UMV')
                   AND is_role_assigned (GetCurrLogin,
                                         'W_ESR_NDI',
                                         l_wut_code);
        ELSIF p_mode = 10
        THEN                    --Наявність ролі W_ESR_NDI для користувача ІОЦ
            l_wut_code := GetCurrUserWutCode;
            RETURN     l_wut_code IN ('UOC')
                   AND is_role_assigned (GetCurrLogin,
                                         'W_ESR_NDI',
                                         l_wut_code);
        ELSIF p_mode = 11
        THEN --Наявність ролі W_ESR_NDI для користувача ЦА, ДСЗН, ОСЗН, Ценру виплат, ІОЦ + НССС
            l_wut_code := GetCurrUserWutCode;
            RETURN        l_wut_code IN ('UMC',
                                         'UMR',
                                         'UMD',
                                         'UMV',
                                         'UOC')
                      AND is_role_assigned (GetCurrLogin,
                                            'W_ESR_NDI',
                                            l_wut_code)
                   OR l_wut_code IN ('UMD', 'UMV')
                   OR     l_wut_code IN ('UNC')
                      AND is_role_assigned (GetCurrLogin,
                                            'W_ESR_VIEW',
                                            l_wut_code);
        ELSIF p_mode = 12
        THEN --Наявність ролі W_ESR_NDI (для користувача ЦА, ДСЗН, ОСЗН, Ценру виплат, ІОЦ + НССС) або W_ESR_KPAYROLL або W_ESR_BUDGET_INSP
            l_wut_code := GetCurrUserWutCode;
            RETURN        l_wut_code IN ('UMC',
                                         'UMR',
                                         'UMD',
                                         'UMV',
                                         'UOC')
                      AND is_role_assigned (GetCurrLogin,
                                            'W_ESR_NDI',
                                            l_wut_code)
                   OR is_role_assigned (GetCurrLogin,
                                        'W_ESR_KPAYROLL',
                                        l_wut_code)
                   OR is_role_assigned (GetCurrLogin,
                                        'W_ESR_BUDGET_INSP',
                                        l_wut_code)
                   OR     l_wut_code IN ('UNC')
                      AND is_role_assigned (GetCurrLogin,
                                            'W_ESR_VIEW',
                                            l_wut_code);
        ELSIF p_mode = 13
        THEN         --Наявність ролі W_ESR_NDI для користувача ЦА, ІОЦ + НССС
            l_wut_code := GetCurrUserWutCode;
            RETURN        l_wut_code IN ('UMC', 'UOC')
                      AND is_role_assigned (GetCurrLogin,
                                            'W_ESR_NDI',
                                            l_wut_code)
                   OR     l_wut_code IN ('UNC')
                      AND is_role_assigned (GetCurrLogin,
                                            'W_ESR_VIEW',
                                            l_wut_code);
        ELSIF p_mode = 99
        THEN                                        --Наявність ролі W_ESR_DEV
            l_wut_code := GetCurrUserWutCode;
            RETURN is_role_assigned (GetCurrLogin, 'W_ESR_DEV', l_wut_code);
        END IF;

        RETURN FALSE;
    END;

    PROCEDURE check_user_and_raise (p_mode INTEGER)
    IS
    BEGIN
        IF NOT check_user (p_mode)
        THEN
            raise_application_error (-20010, 'Недостатньо прав доступу');
        END IF;
    END;

    FUNCTION b64_encode (p_clob CLOB)
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
            --raise_application_error(-20000, 'len(text_encode)='||length(utl_encode.text_encode(l_buffer, 'CL8MSWIN1251', encoding => utl_encode.base64)));
            l_buffer :=
                UTL_ENCODE.text_encode (l_buffer,
                                        encoding   => UTL_ENCODE.base64);
            l_pos := l_pos + l_amount;
            DBMS_LOB.writeappend (l_clob, LENGTH (l_buffer), l_buffer);
        END LOOP;

        RETURN REPLACE (REPLACE (l_clob, CHR (13), ''), CHR (10), '');
    --RETURN l_clob;
    END;

    FUNCTION b64_decode (p_clob CLOB)
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
                                        encoding   => UTL_ENCODE.base64);
            l_pos := l_pos + l_amount;
            DBMS_LOB.writeappend (l_clob, LENGTH (l_buffer), l_buffer);
        END LOOP;

        RETURN l_clob;
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

    FUNCTION GetKOATFullName (p_koat_id IN NUMBER)
        RETURN VARCHAR2
    IS
        v_res   VARCHAR2 (500);
    BEGIN
        SELECT CASE
                   WHEN k.kaot_id = 1
                   THEN
                       k.kaot_name
                   WHEN k.kaot_tp IN ('O', 'P', 'B')
                   THEN
                       k.kaot_name || ' ' || ktp.dic_sname
                   ELSE
                       ktp.dic_sname || ' ' || k.kaot_name
               END
          INTO v_res
          FROM ndi_katottg  k
               JOIN uss_ndi.dic_dv ktp
                   ON k.kaot_tp = ktp.DIC_VALUE AND ktp.DIC_DIDI = 2004
         WHERE k.kaot_id = p_koat_id;

        RETURN v_res;
    END;

    /*
      --========================================
      PROCEDURE log(p_src            VARCHAR2,
                    p_obj_tp         VARCHAR2,
                    p_obj_id         NUMBER,
                    p_regular_params VARCHAR2,
                    p_lob_param      CLOB DEFAULT NULL)
      IS
      BEGIN
        IKIS_SYS.IKIS_PROCEDURE_LOG.log(upper(p_src),
                                        p_obj_tp,
                                        p_obj_id,
                                        p_regular_params,
                                        p_lob_param);
      END;
    */
    --========================================
    PROCEDURE validate_param (p_val VARCHAR2)
    IS
        l_val   VARCHAR2 (4000);
        l_cnt   NUMBER;
    BEGIN
        IF Ikis_Sysweb.IKIS_HTMLDB_COMMON.validate_param (p_val, 5) > 0
        THEN
            raise_application_error (-20000, 'Помилка вхідних данних!');
        END IF;
    END;

    --========================================

    FUNCTION Check_Dict_Value (p_Value IN VARCHAR2, p_Dict IN VARCHAR2)
        RETURN NUMBER
    IS
        l_Res   NUMBER;
    BEGIN
        EXECUTE IMMEDIATE   'SELECT Sign(COUNT(1)) FROM '
                         || p_Dict
                         || ' WHERE DIC_VALUE = :p'
            INTO l_Res
            USING p_Value;

        RETURN l_Res;
    END;

    PROCEDURE Check_Dict_Value (p_Value IN VARCHAR2, p_Dict IN VARCHAR2)
    IS
    BEGIN
        IF Check_Dict_Value (p_Value, p_Dict) = 0
        THEN
            Raise_Application_error (
                -20000,
                   'Значення ['
                || p_Value
                || '] не знайдено у довіднику ['
                || p_Dict
                || ']');
        END IF;
    END;

    --Отримання типу інстансу бази
    FUNCTION get_inctance_type
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN g_instance_type;
    END;

    --Визначення можливості редагування запису
    FUNCTION can_edit_record (p_record_src VARCHAR2)
        RETURN VARCHAR2
    IS
    BEGIN
        IF p_record_src = 'DEV' AND g_instance_type = 'DEV'
        THEN                                               --для бази розробки
            RETURN 'T';
        ELSIF p_record_src = 'USR' AND g_instance_type IN ('TEST', 'PROM')
        THEN                                   --для користувацьких довідників
            RETURN 'T';
        ELSE
            RETURN 'F';                               --Не можна чіпати запис.
        END IF;
    END;

    --Визанчення джерела записів довідників
    FUNCTION get_record_src
        RETURN VARCHAR2
    IS
    BEGIN
        IF g_instance_type = 'DEV'
        THEN                                               --для бази розробки
            RETURN 'DEV';
        ELSIF g_instance_type IN ('TEST', 'PROM')
        THEN                                   --для користувацьких довідників
            RETURN 'USR';
        ELSE
            raise_application_error (
                -20000,
                'Не можу визначити тип інстансу - ведення довідників неможливе!');
        END IF;
    END;

    --Визанчення можливості зміни записів
    PROCEDURE check_record_src (p_record_src VARCHAR2)
    IS
    BEGIN
        IF can_edit_record (p_record_src) = 'F'
        THEN
            raise_application_error (-20000, 'Не можу змінювати цей запис!');
        END IF;
    END;
BEGIN
    -- Initialization
    gINSTANCE_LOCK_NAME := 'USS_NDI:';
    g_instance_type :=
        ikis_sys.ikis_parameter_util.GetParameter1 (
            p_par_code      => 'APP_INSTNACE_TYPE',
            p_par_ss_code   => 'IKIS_SYS');
END TOOLS;
/