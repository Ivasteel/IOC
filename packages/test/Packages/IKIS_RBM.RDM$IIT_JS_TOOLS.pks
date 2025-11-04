/* Formatted on 8/12/2025 6:10:44 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_RBM.RDM$IIT_JS_TOOLS
IS
    -- Author  : VANO
    -- Created : 12.11.2015 14:23:49
    -- Purpose : Функції підплючення IIT-криптографії  (JS) в html-сторінку APEX

    PROCEDURE CryptoProxy;

    PROCEDURE TestCProxy (p_url             VARCHAR2,
                          p_request         VARCHAR2,
                          p_response    OUT CLOB,
                          p_response1   OUT BLOB);

    PROCEDURE DrawJSTools;
END RDM$IIT_JS_TOOLS;
/


GRANT EXECUTE ON IKIS_RBM.RDM$IIT_JS_TOOLS TO DNET_PROXY
/

GRANT EXECUTE ON IKIS_RBM.RDM$IIT_JS_TOOLS TO II01RC_RBMWEB_COMMON
/

GRANT EXECUTE ON IKIS_RBM.RDM$IIT_JS_TOOLS TO PORTAL_PROXY
/


/* Formatted on 8/12/2025 6:10:51 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_RBM.RDM$IIT_JS_TOOLS
IS
    PROCEDURE CryptoProxy
    IS
        l_response    CLOB;
        l_response1   BLOB;
    BEGIN
        TestCProxy (APEX_APPLICATION.g_x02,
                    APEX_APPLICATION.g_x03,
                    l_response,
                    l_response1);
        --htp.p(l_response);
        WPG_DOCLOAD.download_file (l_response1);
    END;

    PROCEDURE TestCProxy (p_url             VARCHAR2,
                          p_request         VARCHAR2,
                          p_response    OUT CLOB,
                          p_response1   OUT BLOB)
    IS
        req           UTL_HTTP.req;
        res           UTL_HTTP.resp;
        url           VARCHAR2 (4000) := 'http://ca.informjust.ua:80/services/cmp/';
        name          VARCHAR2 (4000);
        buffer        VARCHAR2 (4000);
        content64     VARCHAR2 (4000)
            := 'MIGHBgkqhkiG9w0BBwGgegR4DQAAAAAAAAACAAAAv7H/R2rc51/lclSvhmkA+6+OoI5t2MK4VgG3Ra779orjjsaF/B5hbvT5fVgMX7OONavRV3jgBMSz8MM3UILoZAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAEAAAAAAAAA';
        l_tmp         RAW (4000);
        content       RAW (4000);
        l_blob        BLOB;
        l_raw         RAW (32767);
        l_clob        CLOB;
        l_clob1       CLOB;
        l_tmp_clob    CLOB;
        l_tmp_clob1   CLOB;

        PROCEDURE CLS
        IS
        BEGIN
            IF req.private_hndl IS NOT NULL
            THEN
                UTL_HTTP.end_request (req);
            END IF;

            IF res.private_hndl IS NOT NULL
            THEN
                UTL_HTTP.end_response (res);
            END IF;
        END;
    BEGIN
        IF p_url IS NOT NULL
        THEN
            url := p_url;
        END IF;

        IF p_request IS NOT NULL
        THEN
            content64 := p_request;
        END IF;

        l_tmp := UTL_RAW.cast_to_raw (content64);
        content := UTL_ENCODE.base64_decode (l_tmp);

        UTL_HTTP.set_proxy ('172.16.2.32:8888');
        UTL_HTTP.clear_cookies ();
        UTL_HTTP.set_transfer_timeout (3);
        req := UTL_HTTP.begin_request (url, 'POST');
        UTL_HTTP.set_transfer_timeout (req, 3);
        UTL_HTTP.set_header (req, 'Host', 'ca.informjust.ua');
        UTL_HTTP.set_header (req,
                             'Content-Type',
                             'X-user/base64-data; charset=UTF-8');
        UTL_HTTP.set_header (req, 'Content-Length', LENGTH (content) / 2);

        UTL_HTTP.write_raw (req, content);

        res := UTL_HTTP.get_response (req, TRUE);

        DBMS_LOB.createtemporary (l_blob, FALSE);

        BEGIN
            LOOP
                UTL_HTTP.read_raw (res, l_raw, 32766);
                DBMS_LOB.writeappend (l_blob, UTL_RAW.LENGTH (l_raw), l_raw);
            END LOOP;
        EXCEPTION
            WHEN UTL_HTTP.end_of_body
            THEN
                UTL_HTTP.end_response (res);
        END;

        l_tmp_clob := TOOLS.ConvertBlobToBase64 (l_blob, 1);
        l_clob :=
            REPLACE (REPLACE (l_tmp_clob, CHR (13) || CHR (10)), CHR (10));

        --  l_tmp_clob1 := TOOLS.ConvertClobToBase64(l_clob1);
        --  l_clob := REPLACE(REPLACE(l_tmp_clob1, chr(13)||chr(10)), chr(10));

        --  DBMS_LOB.createtemporary(l_clob1, FALSE);
        --  dbms_lob.append(l_clob1, TRIM(to_char(dbms_lob.getlength(l_clob), 'XXXXXXXX'))||CHR(13)||CHR(10));
        --  dbms_lob.append(l_clob1, l_clob);
        --  dbms_lob.append(l_clob1, chr(13)||chr(10)||'0'||chr(13)||chr(10)||chr(13));

        INSERT INTO TMP_TEST_LOB (x, dt, y)
             VALUES (l_blob, SYSDATE, l_clob);

        --  htp.p('payload_length: '||dbms_lob.getlength(l_blob));

        CLS;
        COMMIT;


        --  l_tmp_clob := TOOLS.ConvertBlobToBase64(l_blob, 1);
        --  l_clob := replace(l_tmp_clob,
        --  htp.p('payload_length_clob: '||dbms_lob.getlength(l_clob));

        p_response := l_clob;
        p_response1 := l_blob;
    EXCEPTION
        WHEN OTHERS
        THEN
            BEGIN
                CLS;
                RAISE;
            END;
    END;

    PROCEDURE DrawJSTools
    IS
    BEGIN
        RETURN;
        HTP.p ('   <select id="CAsServersSelect" style="width: 100%">');
        HTP.p ('   <div class="SubMenuContent">');
        HTP.p ('     <div class="TextLabel">Особистий ключ:</div>');
        HTP.p ('     <div>');
        HTP.p (
            '       <input id="PKeyFileName" class="PKeyFileNameEdit" readonly="true" onclick="document.getElementById(''PKeyFileInput'').click();" style="width:200px;float:left;margin-top:3px" type="text">');
        HTP.p (
            '       <div id="buttonitem" style="margin-left:0px;padding-left:10px">');
        HTP.p (
            '         <a id="PKeySelectFileButton" style="cursor:pointer; pointer-events:auto;" href="javascript:void(0);" title="Обрати" onclick="document.getElementById(''PKeyFileInput'').click();">Обрати</a>');
        HTP.p (
            '         <input id="PKeyFileInput" multiple="false" type="file">');
        HTP.p ('       </div>');
        HTP.p ('     </div>');
        HTP.p ('     <div class="TextLabel">Пароль захисту ключа:</div>');
        HTP.p ('     <div>');
        HTP.p (
            '       <input id="PKeyPassword" class="PasswordEdit" xdisabled="disabled" style="width:200px;float:left;margin-top:3px" type="password">');
        HTP.p (
            '       <div id="buttonitem" style="margin-left:0px;padding-left:10px">');
        HTP.p (
            '         <a id="PKeyReadButton" style="cursor:pointer;" href="javascript:void(0);" title="Зчитати" onclick="euSignTest.readPrivateKeyButtonClick()">Зчитати</a>');
        HTP.p ('       </div>');
        HTP.p ('     </div>');
        HTP.p ('     <div id="PKCertsSelectZone" hidden="">');
        HTP.p ('       <div class="FileDropZone" id="PKCertsDropZone">');
        HTP.p ('         <div class="FileDropZoneBorder">');
        HTP.p ('           <div class="FileDropZoneMessage">');
        HTP.p ('             <span>Перетягніть або </span><br><br>');
        HTP.p (
            '             <div id="buttonitem" style="float:center; display:inline-block;">');
        HTP.p (
            '               <a id="ChoosePKCertsButton" style="cursor:pointer; pointer-events:auto;" href="javascript:void(0);" title="Оберіть" onclick="document.getElementById(''ChoosePKCertsInput'').click();">Оберіть</a>');
        HTP.p (
            '               <input id="ChoosePKCertsInput" multiple="true" type="file">');
        HTP.p ('             </div>');
        HTP.p ('             <br><br>');
        HTP.p (
            '             <span>файл(и) з сертифікатом(ами)</span><br><br>');
        HTP.p (
            '             <span>(зазвичай, з розширенням cer, crt)</span>');
        HTP.p ('           </div>');
        HTP.p ('         </div>');
        HTP.p ('       </div>');
        HTP.p ('       <br>');
        HTP.p ('       <div class="TextLabel">Обрані сертифікати:</div>');
        HTP.p (
            '       <output id="SelectedPKCertsList" style="padding-left:1em;">Сертифікати відкритого ключа не обрано<br></output>');
        HTP.p ('       <br><br>');
        HTP.p ('     </div>');
        HTP.p ('   </div>');


        HTP.p (
            '<span id="status" style="font-weight: normal;">(завантаження...)</span>');
        HTP.p ('<output id="SelectedCertsList"></output>');
        HTP.p ('<output id="SelectedCRLsList"></output>');
        HTP.p (
            '   <span class="TextInTextImageContainer" id="ChoosePKFileText">Оберіть файл з особистим ключем (зазвичай з ім`ям Key-6.dat) та вкажіть пароль захисту</span>');
        HTP.p (
            '<input id="CertsAndCRLsFiles" type="file" class="SelectFile" name="files[]" multiple />');
    END;
END RDM$IIT_JS_TOOLS;
/