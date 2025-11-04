/* Formatted on 8/12/2025 6:11:40 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYSWEB.Ikis_Htmldb_Ui
IS
    -- Author  : SHOSTAK
    -- Created : 22.04.2019 16:56:40
    -- Purpose : Рендеринг формы логина для приложений APEX; скрипты для аутентификации по закрытым ключам

    --------------------------------------------------------------------------
    --Возвращает JS массив с типами ключей для входа
    --------------------------------------------------------------------------
    FUNCTION Get_Key_Types (p_Login_Tp VARCHAR2 DEFAULT NULL)
        RETURN VARCHAR2;

    --------------------------------------------------------------------------
    --Возвращает JS объект с параметрами криптографической библиотеки
    --------------------------------------------------------------------------
    FUNCTION Get_Crypto_Params
        RETURN VARCHAR2;

    --------------------------------------------------------------------------
    --Отрисовка страницы логина для APEX
    --------------------------------------------------------------------------
    PROCEDURE Render_Login_Page (p_Attempt_Session   IN VARCHAR2,
                                 p_Title                VARCHAR2);

    --------------------------------------------------------------------------
    --Возвращает идентификатор сессии, текущей попытки логина в приложение APEX
    --------------------------------------------------------------------------
    FUNCTION Get_Attempt_Session
        RETURN VARCHAR2;

    --------------------------------------------------------------------------
    --Возвращает тип логина, под которым ползователь совершает
    --текущую попытку входа в приложение APEX
    --------------------------------------------------------------------------
    FUNCTION Get_Login_Tp
        RETURN VARCHAR2;
END Ikis_Htmldb_Ui;
/


/* Formatted on 8/12/2025 6:11:43 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_SYSWEB.Ikis_Htmldb_Ui
IS
    --Название полей в APEX
    c_Field_Name_Attempt_Session   CONSTANT VARCHAR2 (3) := 'f06';
    c_Field_Name_Login_Tp          CONSTANT VARCHAR2 (3) := 'f07';

    --------------------------------------------------------------------------
    --Возвращает имя пользователя, по которому пользователь ранее логинился
    --------------------------------------------------------------------------
    FUNCTION Get_Username_Cookie
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN OWA_COOKIE.Get ('LOGIN_USERNAME_COOKIE').Vals (1);
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN '';
    END;

    --------------------------------------------------------------------------
    --Возвращает тип ключа(ЕЦП), по которому пользователь ранее логинился
    --------------------------------------------------------------------------
    FUNCTION Get_Key_Tp_Cookie
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN OWA_COOKIE.Get ('KEY_TYPE_COOKIE').Vals (1);
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN '';
    END;

    --------------------------------------------------------------------------
    --Возвращает JS массив с типами ключей для входа
    --------------------------------------------------------------------------
    FUNCTION Get_Key_Types (p_Login_Tp VARCHAR2 DEFAULT NULL)
        RETURN VARCHAR2
    IS
        v_Result    VARCHAR2 (32000) := '';
        v_Ca_Data   VARCHAR2 (32000) := '';
    BEGIN
        FOR Rec
            IN (  SELECT t.Lkt_Id,
                         t.Lkt_Name,
                         t.Lkt_Login_Tp,
                         t.Lkt_Key_Mask,
                         t.Lkt_Storage_Tp,
                         c.Wca_Id,
                         c.Wca_Issuer_Cn,
                         c.Wca_Ocsp_Address,
                         c.Wca_Ocsp_Port,
                         c.Wca_Ocsp_Point_Address,
                         c.Wca_Ocsp_Point_Port,
                         c.Wca_Cmp_Address,
                         c.Wca_Cmp_Port,
                         c.Wca_Tsp_Address,
                         c.Wca_Tsp_Port
                    FROM w_Login_Key_Type t
                         LEFT JOIN w_Cert_Authority c ON t.Lkt_Ca = c.Wca_Id
                   WHERE     t.Lkt_Is_Active = 'A'
                         AND t.Lkt_Login_Tp = NVL (p_Login_Tp, t.Lkt_Login_Tp)
                ORDER BY t.Lkt_Num)
        LOOP
            IF Rec.Wca_Id IS NOT NULL
            THEN
                v_Ca_Data :=
                       '{"ocspAddress": "'
                    || Rec.Wca_Ocsp_Address
                    || '", "ocspPort": "'
                    || Rec.Wca_Ocsp_Port
                    || '", "ocspPointAddress": "'
                    || Rec.Wca_Ocsp_Point_Address
                    || '", "ocspPointPort": "'
                    || Rec.Wca_Ocsp_Point_Port
                    || '", "tspAddress": "'
                    || Rec.Wca_Tsp_Address
                    || '", "tspPort": "'
                    || Rec.Wca_Tsp_Port
                    || '", "cmpAddress": "'
                    || Rec.Wca_Cmp_Address
                    || '", "cmpPort": "'
                    || Rec.Wca_Cmp_Port
                    || '"}';
            ELSE
                v_Ca_Data := 'null';
            END IF;

            v_Result :=
                   v_Result
                || '{"id": '
                || Rec.Lkt_Id
                || ', "name": "'
                || Rec.Lkt_Name
                || '", "loginType": "'
                || Rec.Lkt_Login_Tp
                || '", "keyStorageType": "'
                || Rec.Lkt_Storage_Tp
                || '", "keyMediaTypeMask":"'
                || Rec.Lkt_Key_Mask
                || '", "caData": '
                || v_Ca_Data
                || '},';
        END LOOP;

        v_Result := '[' || RTRIM (v_Result, ',') || ']';
        RETURN v_Result;
    END;

    --------------------------------------------------------------------------
    --Возвращает JS объект с параметрами криптографической библиотеки
    --------------------------------------------------------------------------
    FUNCTION Get_Crypto_Params
        RETURN VARCHAR2
    IS
        v_Result            VARCHAR2 (32000);
        v_Proxy_Address     VARCHAR2 (255);
        v_Proxy_Port        VARCHAR2 (255);
        v_Pfu_Cert_Serial   VARCHAR2 (255);
        v_Pfu_Cert_Issuer   VARCHAR2 (255);
        v_File_Storage      VARCHAR2 (255);
        v_Agent_Port        VARCHAR2 (255);
    BEGIN
        v_Proxy_Address :=
            Ikis_Sys.Ikis_Common.Getapptparam ('WEB_CRYPTO_PROXY_ADDR');
        v_Proxy_Port :=
            Ikis_Sys.Ikis_Common.Getapptparam ('WEB_CRYPTO_PROXY_PORT');
        v_Pfu_Cert_Serial :=
            Ikis_Sys.Ikis_Common.Getapptparam ('WEB_PFU_CERT_SERIAL');
        v_Pfu_Cert_Issuer :=
            Ikis_Sys.Ikis_Common.Getapptparam ('WEB_PFU_CERT_ISSUER');
        v_File_Storage :=
            Ikis_Sys.Ikis_Common.Getapptparam ('WEB_CERT_STORAGE');
        v_Agent_Port :=
            Ikis_Sys.Ikis_Common.Getapptparam ('WEB_CRYPTO_AGENT_PORT');
        v_Result :=
               '{"proxyAddress": "'
            || v_Proxy_Address
            || '", "proxyPort": "'
            || v_Proxy_Port
            || '", "pfuCertSerial": "'
            || v_Pfu_Cert_Serial
            || '", "pfuCertIssuer": "'
            || v_Pfu_Cert_Issuer
            || '", "fileStorage": "'
            || v_File_Storage
            || '", "agentPort": "'
            || v_Agent_Port
            || '"}';
        RETURN v_Result;
    END;

    --------------------------------------------------------------------------
    --"Отрисовка" скриптов логина для APEX
    --------------------------------------------------------------------------
    PROCEDURE Render_Login_Scripts
    IS
    BEGIN
        --Подключаем скрипты IIT библиотеки
        HTP.p (
            '<script type="text/JavaScript" src="/i/signature/euutils.js"></script>');
        HTP.p (
            '<script type="text/JavaScript" src="/i/signature/eusw.js"></script>');
        --"Отрисовываем" скрипты логина по ЕЦП
        HTP.p (
            '<script type="text/JavaScript" src="/i/signature/mt.crypto.agent.js"></script>');
        HTP.p (
            '<script type="text/JavaScript" src="/i/signature/mt.crypto.login.js"></script>');
        HTP.p ('<script>');
        HTP.p (
               '
         var mtCrLogin;
         var keyTypes = '
            || Get_Key_Types
            || ';
         renderKeyTypes();

         function renderKeyTypes(){
              var keyTypeSelector = document.getElementById("keyTypeSelector");
              var selectedValue = -1;
              for(var i=0; i < keyTypes.length; i++){
                 var keyTypeName = keyTypes[i].name;
                 var keyTypeId = keyTypes[i].id;
                 var opt = document.createElement("option");
                 if(keyTypeId == "'
            || Get_Key_Tp_Cookie
            || '"){
                    opt.selected = true;
                    selectedValue = keyTypeId;
                 }
                 opt.value = keyTypeId;
                 opt.innerHTML = keyTypeName;
                 keyTypeSelector.appendChild(opt);
              }
              keyTypeChanged(selectedValue);
          }

         function login() {
          var keyPath;
          var keyPassword;
          var isSignSelected;
          var isCardSelected;

          var keyTypeId = getKeyTypeId();
          var keyType = getKeyType(keyTypeId);

          if (keyType.loginType == "SIGN"){
            keyPassword = getKeyPassword();
            keyPath = getKeyPath();
            isSignSelected = keyPath && keyPassword;
          }

          if (keyType.loginType == "CARD"){
            keyPassword = getCardPassword();
            isCardSelected = keyPassword && true;
          }

          if (isSignSelected) {
            loginBySign(keyType, keyPassword);
          } else if (isCardSelected) {
            loginByCard(keyType, keyPassword);
          } else {
            apex.submit();
          }
          setAuthCookies(keyType);
        }

        function loginBySign(keyType, keyPassword){
            showSpinner();
            var cryptoParams = '
            || Get_Crypto_Params
            || ';
            cryptoParams.rootCertUrl = "/i/signature/CACertificates.p7b";
            var callbacks = {
              errorHandler: showError,
              loginHandler: setPayload
            };

            if(!mtCrLogin){
              mtCrLogin = MtCryptoLogin(cryptoParams, callbacks);
            }

            var params = {
              keyType: keyType,
              keyFile: document.getElementById("file-input").files[0],
              keyPassword: keyPassword,
              attemptSession: $("#ATTEMPT_SESSION").val()
            };

            setTimeout(function(){mtCrLogin.execute(params, callbacks);}, 1);
        }

        function loginByCard(keyType, keyPassword){
            showSpinner();
            var cryptoParams = '
            || Get_Crypto_Params
            || ';
            cryptoParams.rootCertUrl = "/i/signature/CACertificates.p7b";
            var callbacks = {
              errorHandler: showError,
              loginHandler: setPayload
            };

            if(!mtCrLogin){
              mtCrLogin = MtCryptoLogin(cryptoParams, callbacks);
            }


            var params = {
              keyType: keyType,
              keyPassword: keyPassword,
              attemptSession: $("#ATTEMPT_SESSION").val()
            };
            setTimeout(function(){mtCrLogin.execute(params, callbacks);}, 1);
        }

        function setAuthCookies(){
          var keyTypeId = getKeyTypeId();
          setCookie("KEY_TYPE_COOKIE", keyTypeId);

          var username = getUserName();
          setCookie("LOGIN_USERNAME_COOKIE", username);
        }

        function setPayload(attemptSession, payload, loginType) {
          hideSpinner();
          $s("ATTEMPT_SESSION", attemptSession);
          $s("LOGIN_TYPE", loginType);
          console.log("login type: " + loginType);
          apex.server.process(
            "SetPayload", {
            x01: attemptSession,
            x02: payload,
            x03: loginType,
            pageItems: "#'
            || c_Field_Name_Attempt_Session
            || ',#'
            || c_Field_Name_Login_Tp
            || '"
          }, {
            success: function (pData) {
              console.log(pData);
              apex.submit();
            },
            dataType: "text"
          });
        }

        function handleFiles(files) {
          if (files == undefined || files.length == 0) {
            return;
          }
          var keyPath = $("#file-input").val().replace(/^.*[\\\/]/, "");
          setKeyPath(keyPath);
        }

        function keyTypeChanged(keyTypeId) {
          var fileSignGroup = document.getElementById("fileSignGroup");
          var cardGroup = document.getElementById("cardGroup");
          var loginType = getKeyType(keyTypeId).loginType;
          if (loginType == "SIGN") {
            fileSignGroup.style.display = "block";
          } else {
            fileSignGroup.style.display = "none";
          }

          if (loginType == "CARD"){
             cardGroup.style.display = "block";
          } else {
             cardGroup.style.display = "none";
          }

          var selector = document.getElementById("keyTypeSelector");
          selector.title =  selector.options[selector.selectedIndex].text;
        }

        function getKeyType(keyTypeId){
            for (var i = 0; i < keyTypes.length; i++) {
               if (keyTypes[i].id == keyTypeId) {
                  return keyTypes[i];
               }
            }
         }

        function getUserName(){
          return $("#USERNAME_INPUT").val();
        }

        function getKeyTypeId() {
          return $("#keyTypeSelector").val();
        }

        function getKeyPath() {
          return $("#KEY_PATH").val();
        }

        function setKeyPath(path) {
          $("#KEY_PATH").val(path);
        }

        function getKeyPassword() {
          return $("#KEY_PASSWORD").val();
        }

        function getCardPassword() {
          return $("#CARD_PASSWORD").val();
        }

        function showError(errorMsg) {
          apex.message.showErrors([{
                type: "error",
                location: ["page", "inline"],
                pageItem: "",
                message: errorMsg,
                unsafe: false
              }
            ]);
            hideSpinner();
        }

        function showSpinner(){
          lSpinner$ = apex.util.showSpinner();
        }

        function hideSpinner(){
           if(lSpinner$){
             lSpinner$.remove();
           }
        }

        function setCookie(name, value, options) {
              options = options || {};

              var expires = options.expires;

              if (typeof expires == "number" && expires) {
                var d = new Date();
                d.setTime(d.getTime() + expires * 1000);
                expires = options.expires = d;
              }
              if (expires && expires.toUTCString) {
                options.expires = expires.toUTCString();
              }

              value = encodeURIComponent(value);

              var updatedCookie = name + "=" + value;

              for (var propName in options) {
                updatedCookie += "; " + propName;
                var propValue = options[propName];
                if (propValue !== true) {
                  updatedCookie += "=" + propValue;
                }
              }

              document.cookie = updatedCookie;
            }

            function keyPress(e){
                if (e.keyCode == 13) {
                  login();
              }
            }');
        HTP.p ('</script>');
    END;

    --------------------------------------------------------------------------
    --Отрисовка страницы логина для APEX
    --------------------------------------------------------------------------
    PROCEDURE Render_Login_Page (p_Attempt_Session   IN VARCHAR2,
                                 p_Title                VARCHAR2)
    IS
        v_Theme                VARCHAR2 (1000);
        v_Login_Form_Style     VARCHAR2 (32000) := '';
        v_Is_Universal_Theme   BOOLEAN;
        l_Sql                  VARCHAR2 (4000)
            := 'SELECT MAX(a.Theme_Name) FROM Apex_Application_Themes a WHERE a.Application_Id = :p1 AND a.Is_Current = ''Yes'' ';
    BEGIN
        --Определяем текущую тему APEX-а
        /*
        SELECT MAX(a.Theme_Name)
          INTO v_Theme
          FROM Apex_Application_Themes a
         WHERE a.Application_Id = v('APP_ID')
               AND a.Is_Current = 'Yes';
        */

        EXECUTE IMMEDIATE l_Sql
            INTO v_Theme
            USING v ('APP_ID');

        --Тема от 3-го APEX, которая используется в большинстве приложений, в отличие от универсальной темы 5-го не содержит шаблона формы логина
        --поэтому "рисуем" кастомный CSS для 3-го
        v_Is_Universal_Theme := UPPER (v_Theme) LIKE '%UNIVERSAL%';

        IF NOT v_Is_Universal_Theme
        THEN
            v_Login_Form_Style := ('
          #loginForm{
                    width: 500px;
                    padding-bottom: 15px;
                    display: block;
                    border: 1px solid rgba(0,0,0,.1);
                    border-radius: 2px;
                    box-shadow: 0 2px 4px -2px #aaa;
                    margin-top: 20%;
                    margin-left: auto;
                    margin-right: auto;
          }

          *{
            font-size: 10.6 pt;
          }');
        END IF;

        HTP.p (
               '<style>
          hr{
             border: none;
             height: 1px;
             color: #dfdfdf;
             background-color: #dfdfdf;
          }

          label {
            display: inline-block;
            width: 170px;
            text-align: left;
            margin-bottom: 20px;
            margin-right: 3px;
          }

          select,
          input {
            height: 25px;
            width: 250px;
            padding-left: 4px;
            text-shadow: none;
            border: 1px solid;
            border-color: #aaa;
            border-radius: 2px;
            transition: background-color .1s ease, border .1s ease;
            background-color: #f9f9f9;
          }

          '
            || CHR (64)
            || '-moz-document url-prefix() {
            select {
              padding-left: 0;
            }
          }

          select {
            -webkit-appearance: none;
            -moz-appearance: none;
            background-image: url("data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSI0MDAiIGhlaWdodD0iMjAwIiB2aWV3Qm94PSItOTkuNSAwLjUgNDAwIDIwMCIgZW5hYmxlLWJhY2tncm91bmQ9Im5ldyAtOTkuNSAwLjUgNDAwIDIwMCI+PHBhdGggZmlsbD0iIzQ0NCIgZD0iTTE1Ni4yNSA3My43YzAgMS42LS42MTIgMy4yLTEuODI1IDQuNDI1bC01NC40MjUgNTQuNDI1LTU0LjQyNS01NC40MjVjLTIuNDM4LTIuNDM4LTIuNDM4LTYuNCAwLTguODM3czYuNC0yLjQzOCA4LjgzNyAwbDQ1LjU4OCA0NS41NzQgNDUuNTc1LTQ1LjU3NWMyLjQzOC0yLjQzOCA2LjM5OS0yLjQzOCA4LjgzNyAwIDEuMjI2IDEuMjI2IDEuODM4IDIuODI1IDEuODM4IDQuNDEzeiIvPjwvc3ZnPg==");
            background-repeat: no-repeat;
            background-position: 100% 50%;
            background-size: 32px 16px;
            padding-right: 3.2rem;
          }

          select::-ms-expand {
              display: none;
          }

          .auth-button {
            -webkit-appearance: none;
            background: 0 0;
            background-clip: padding-box;
            cursor: pointer;
            display: inline-block;
            font-size: 11pt;
            margin: 0;
            text-align: center;
            -webkit-user-select: none;
            -moz-user-select: none;
            -ms-user-select: none;
            user-select: none;
            color: #383838;
            background-color: #f8f8f8;
            border: none;
            box-shadow: 0 0 0 1px #aaa inset;
            border-radius: 2px;
            text-shadow: none;
            transition: background-color .2s ease, box-shadow .2s ease, color .2s ease;

            height: 25px;
            width: 250px;

            vertical-align: top;
          }

          select:hover,
          input:hover,
          .auth-button:hover {
            background-color: #fff!important;
          }

          select:focus,
          input:focus {
            background-color: #fff!important;
            border-color: #0572CE!important;
            outline: none;
          }

         .auth-button:focus{
              outline: 1px solid #198cca;
          }

         .auth-button:active{
                 box-shadow: 0 0 0 1px rgba(0,0,0,.15) inset,0 2px 2px rgba(0,0,0,.1) inset!important;
                 background-color: #dedede!important;
                 outline: none;
          }

          #browseButton{
              border-radius: 0 2px 2px 0;
          }


          '
            || v_Login_Form_Style
            || '
  </style>');
        HTP.p (
               '<div id="loginForm" '
            || (CASE
                    WHEN v_Is_Universal_Theme THEN ''
                    ELSE 'align="center"'
                END)
            || '><div id="loginFormTitle"><h3>'
            || p_Title
            || '</h3></div><hr style="margin-bottom: 10px">
           <label for="USERNAME_INPUT">Користувач</label><input id="USERNAME_INPUT" name="f01" type="text" value="'
            || Get_Username_Cookie
            || '"><br>');
        HTP.p (
            q'[
  <label for="PASSWORD_INPUT">Пароль</label><input id="PASSWORD_INPUT" name="f02" type="password" onkeypress="keyPress(event)"><br>
  <label for="keyTypeSelector" style="width: 166px">Тип ЕЦП</label>
  <select name="f03" id="keyTypeSelector" onchange="keyTypeChanged(this.options[this.selectedIndex].value);"></select><br>
  <div id="fileSignGroup" style="display: none">
    <label for="KEY_PATH">Файл особистого ключа</label><input id="KEY_PATH" name="f04" type="text" style="width: 186px" disabled>
    <input id="file-input" type="file" name="name" style="display: none;" onchange="handleFiles(this.files);">
    <span><button id="browseButton" type="button" class="auth-button" style="width: 65px; margin-left: -5px;" onclick="$('#file-input').trigger('click');">Обрати</button></span>
    <label for="KEY_PASSWORD">Пароль особистого ключа</label><input id="KEY_PASSWORD" name="f05" type="password" onkeypress="keyPress(event)"><br>
  </div>
  <div id="cardGroup">
     <label for="CARD_PASSWORD">Пароль особистого ключа</label><input id="CARD_PASSWORD" name="f08" type="password" onkeypress="keyPress(event)"><br>
  </div>
  <button id="loginButton" type="button" class="auth-button" style="margin-left: 173px;" onClick="login();" onkeypress="keyPress(event)">Вхід</button>]');
        HTP.p ('</div>');
        HTP.p (
               '<input type="hidden" id="ATTEMPT_SESSION" name="'
            || c_Field_Name_Attempt_Session
            || '" value="'
            || p_Attempt_Session
            || '">');
        HTP.p (
               '<input type="hidden" id="LOGIN_TYPE" name="'
            || c_Field_Name_Login_Tp
            || '" value="">');
        Render_Login_Scripts;
    END;

    --------------------------------------------------------------------------
    --Возвращает идентификатор сессии, текущей попытки логина в приложение APEX
    --------------------------------------------------------------------------
    FUNCTION Get_Attempt_Session
        RETURN VARCHAR2
    IS
        v_Result   w_Login_Attempts.Wla_Session%TYPE;
    BEGIN
        EXECUTE IMMEDIATE   'begin :result :=  Apex_Application.g_'
                         || c_Field_Name_Attempt_Session
                         || '(1); end;'
            USING OUT v_Result;

        RETURN v_Result;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN NULL;
    END;

    --------------------------------------------------------------------------
    --Возвращает тип логина, под которым ползователь совершает
    --текущую попытку входа в приложение APEX
    --------------------------------------------------------------------------
    FUNCTION Get_Login_Tp
        RETURN VARCHAR2
    IS
        v_Result   w_Login_Attempts.Wla_Login_Tp%TYPE;
    BEGIN
        EXECUTE IMMEDIATE   'begin :result :=  Apex_Application.g_'
                         || c_Field_Name_Login_Tp
                         || '(1); end;'
            USING OUT v_Result;

        RETURN v_Result;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN NULL;
    END;
END Ikis_Htmldb_Ui;
/