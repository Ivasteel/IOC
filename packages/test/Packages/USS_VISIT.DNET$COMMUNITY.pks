/* Formatted on 8/12/2025 5:59:41 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_VISIT.DNET$COMMUNITY
IS
    -- Author  : SBOND
    -- Created : 20.05.2022 10:06:59
    -- Purpose : обробка звернень ВПО

    --01.09.2023 Пакет ставить на пром нельзя #88585
    --согласовать с Бондаруком С.

    --Обмін з ПК Соціальна громада реєстрація звернень ВПО щодо допомоги на проживання ПКМУ 332 в ЄІССС для подальшого опрацювання
    /*
    function IsAllowProcessed(
      p_ap_id in number,
      p_ap_ext_ident2 number,
      p_aps_id in number,
      p_comment out varchar2
    ) return number;*/

    FUNCTION ExistAppelCheck (p_ap_id IN NUMBER, p_ap_ext_ident2 IN NUMBER)
        RETURN NUMBER;

    FUNCTION GetApIdByExtid (p_ap_ext_id2 IN NUMBER)
        RETURN NUMBER;

    FUNCTION GetApByAps (p_aps_id IN NUMBER, p_aps_nst IN NUMBER)
        RETURN NUMBER;

    FUNCTION GetApsByAp (p_ap_id IN NUMBER, p_aps_nst IN NUMBER)
        RETURN NUMBER;

    FUNCTION DecodeRefDocType2Ndt (p_refDocType_id     IN NUMBER := NULL,
                                   p_refDocType_name   IN VARCHAR2 := NULL)
        RETURN NUMBER;

    FUNCTION DecodeOrg (p_org IN NUMBER, p_type VARCHAR2:= 'COM2VST')
        RETURN NUMBER;

    PROCEDURE Save_Appeal (p_ap_id               IN     NUMBER,
                           p_new_id                 OUT NUMBER,
                           p_ap_num              IN     VARCHAR2,
                           p_ap_reg_dt           IN     DATE,
                           p_rn_id               IN     NUMBER,
                           p_ap_ext_ident        IN     NUMBER,
                           p_ap_src              IN     VARCHAR2,
                           p_com_org             IN     NUMBER,
                           p_Ap_Is_Second        IN     VARCHAR2 := 'F',
                           p_Ap_Is_Ext_Process   IN     VARCHAR2 := 'F',
                           p_Ap_Tp               IN     VARCHAR2,
                           p_ap_ext_ident2       IN     NUMBER);

    PROCEDURE ChangeStatusAppelDiia (p_ap_id IN NUMBER);

    PROCEDURE ChangeOrgAppelDiia (p_ap_id IN NUMBER, p_org IN NUMBER);

    PROCEDURE Save_Service (p_Aps_Id    IN     NUMBER,
                            p_new_id       OUT NUMBER,
                            p_Aps_Nst   IN     NUMBER,
                            p_Aps_Ap    IN     NUMBER,
                            p_Aps_St    IN     VARCHAR2);

    PROCEDURE Save_Person (
        p_App_Id        IN     Ap_Person.App_Id%TYPE := NULL,
        p_App_Ap        IN     Ap_Person.App_Ap%TYPE := NULL,
        p_App_Tp        IN     Ap_Person.App_Tp%TYPE := NULL,
        p_App_Inn       IN     Ap_Person.App_Inn%TYPE := NULL,
        p_App_Ndt       IN     Ap_Person.App_Ndt%TYPE := NULL,
        p_App_Doc_Num   IN     Ap_Person.App_Doc_Num%TYPE := NULL,
        p_App_Fn        IN     Ap_Person.App_Fn%TYPE := NULL,
        p_App_Mn        IN     Ap_Person.App_Mn%TYPE := NULL,
        p_App_Ln        IN     Ap_Person.App_Ln%TYPE := NULL,
        p_App_Esr_Num   IN     Ap_Person.App_Esr_Num%TYPE := NULL,
        p_Gender        IN     Ap_Person.App_Gender%TYPE := NULL,
        p_App_Vf        IN     Ap_Person.App_Vf%TYPE := NULL,
        p_App_Sc        IN     Ap_Person.App_Sc%TYPE := NULL,
        p_New_Id           OUT Ap_Person.App_Id%TYPE);

    PROCEDURE Save_Person_Doc (p_apd_id    IN     NUMBER,
                               p_new_id       OUT NUMBER,
                               p_apd_ap    IN     NUMBER,
                               p_apd_ndt   IN     NUMBER,
                               p_Apd_Doc   IN     NUMBER,
                               p_apd_app   IN     NUMBER,
                               p_Apd_Dh    IN     NUMBER,
                               p_Apd_Aps   IN     NUMBER,
                               p_Apd_Src   IN     VARCHAR2 := 'COM');

    PROCEDURE Save_Attributes_Doc (
        p_Apda_Id           IN     Ap_Document_Attr.Apda_Id%TYPE,
        p_Apda_Ap           IN     Ap_Document_Attr.Apda_Ap%TYPE,
        p_Apda_Apd          IN     Ap_Document_Attr.Apda_Apd%TYPE,
        p_Apda_Nda          IN     Ap_Document_Attr.Apda_Nda%TYPE,
        p_New_Id               OUT Ap_Document_Attr.Apda_Val_Id%TYPE,
        p_Apda_Val_Int      IN     Ap_Document_Attr.Apda_Val_Int%TYPE := NULL,
        p_Apda_Val_Dt       IN     Ap_Document_Attr.Apda_Val_Dt%TYPE := NULL,
        p_Apda_Val_String   IN     Ap_Document_Attr.Apda_Val_String%TYPE := NULL,
        p_Apda_Val_Id       IN     Ap_Document_Attr.Apda_Val_Id%TYPE := NULL,
        p_Apda_Val_Sum      IN     Ap_Document_Attr.Apda_Val_Sum%TYPE := NULL);

    PROCEDURE Save_Person_Doc_Attribute (p_Ap_id        IN     NUMBER,
                                         p_New_Id          OUT NUMBER,
                                         p_Apd_id       IN     NUMBER,
                                         p_Ndt_id       IN     NUMBER,
                                         p_Doc_Serial   IN     VARCHAR2,
                                         p_Doc_Number   IN     VARCHAR2,
                                         p_Authority    IN     VARCHAR2,
                                         p_Start        IN     DATE,
                                         p_Expired      IN     DATE,
                                         p_Unzr         IN     NUMBER,
                                         p_Birth_Dt     IN     DATE);

    PROCEDURE Decode_Dic_Value (p_Nddc_Tp         IN     VARCHAR2,
                                p_Nddc_Src        IN     VARCHAR2,
                                p_Nddc_Dest       IN     VARCHAR2,
                                p_Nddc_Code_Src   IN     VARCHAR2,
                                p_out                OUT VARCHAR2);

    /*procedure Set_Person_ScId(
      p_apd_id in number,
      p_ap_id in number,
      p_date in date,
      p_sc_id out number,
      p_esr_num out varchar2
    );*/

    PROCEDURE Load_socialcard (p_sc_id            OUT NUMBER,
                               p_sc_unique        OUT VARCHAR2,
                               p_fn            IN     VARCHAR2,
                               p_ln            IN     VARCHAR2,
                               p_mn            IN     VARCHAR2,
                               p_gender        IN     VARCHAR2,
                               p_nationality   IN     VARCHAR2,
                               p_src_dt        IN     DATE,
                               p_birth_dt      IN     DATE,
                               p_inn_num       IN     VARCHAR2,
                               p_inn_ndt       IN     NUMBER,
                               p_doc_ser       IN     VARCHAR2,
                               p_doc_num       IN     VARCHAR2,
                               p_doc_ndt       IN     NUMBER,
                               p_src           IN     VARCHAR2);

    PROCEDURE GetDictionaryId (p_dict_name   IN     VARCHAR2,
                               p_id             OUT NUMBER,
                               p_code01             VARCHAR2,
                               p_code02             VARCHAR2 := NULL,
                               p_code03             NUMBER := NULL);

    PROCEDURE GetDictionaryStr (p_id      IN     VARCHAR2,
                                p_code    IN     VARCHAR2,
                                p_value      OUT VARCHAR2);

    PROCEDURE Save_Payment (
        p_Apm_Id             IN     ap_payment.apm_id%TYPE,
        p_New_Id                OUT ap_payment.apm_id%TYPE,
        p_Apm_Ap             IN     ap_payment.apm_ap%TYPE,
        p_Apm_Aps            IN     ap_payment.apm_aps%TYPE,
        p_Apm_App            IN     ap_payment.apm_app%TYPE,
        p_Apm_Tp             IN     ap_payment.apm_tp%TYPE,
        p_Apm_Index          IN     ap_payment.apm_index%TYPE := NULL,
        p_Apm_Kaot           IN     ap_payment.apm_kaot%TYPE := NULL,
        p_Apm_Nb             IN     ap_payment.apm_nb%TYPE := NULL,
        p_Apm_Account        IN     ap_payment.apm_account%TYPE,
        p_Apm_Need_Account   IN     ap_payment.apm_need_account%TYPE := NULL,
        p_Apm_Street         IN     ap_payment.apm_street%TYPE := NULL,
        p_Apm_Ns             IN     ap_payment.apm_ns%TYPE := NULL,
        p_Apm_Building       IN     ap_payment.apm_building%TYPE := NULL,
        p_Apm_Block          IN     ap_payment.apm_block%TYPE := NULL,
        p_Apm_Apartment      IN     ap_payment.apm_apartment%TYPE := NULL,
        p_Apm_Dppa           IN     ap_payment.apm_dppa%TYPE := NULL);

    PROCEDURE AddAllAttributeToDoc (p_ap_id IN NUMBER);

    PROCEDURE SetAllApealDocumentToHistory (p_ap_id IN NUMBER);

    PROCEDURE Get_Ap_Doc_Info (p_Ap_Id                  NUMBER,
                               p_Ap_Doc             OUT NUMBER,
                               p_Doc_Edit_Allowed   OUT VARCHAR2,
                               p_Docs_Cur           OUT SYS_REFCURSOR,
                               p_Files_Cur          OUT SYS_REFCURSOR);

    PROCEDURE Reg_Appeal_Status_Send (p_ap_id   IN NUMBER,
                                      p_ap_st   IN VARCHAR2 DEFAULT NULL);

    FUNCTION Get_Appeal_Status_Send_Req (p_Ur_Id IN NUMBER)
        RETURN CLOB;

    PROCEDURE Handler_Appeal_Status_Send_Result (
        p_Ur_Id      IN     NUMBER,
        p_Response   IN     CLOB,
        p_Error      IN OUT VARCHAR2);

    --20230412
    --Визначення Ід послуги по коду
    FUNCTION GetNstByComCode (p_code IN VARCHAR2)
        RETURN NUMBER;

    FUNCTION IsAllowProcessed (p_ap_id           IN     NUMBER,
                               p_ap_ext_ident2          NUMBER,
                               p_aps_id          IN     NUMBER,
                               p_comment            OUT VARCHAR2,
                               p_nst_id          IN     NUMBER)
        RETURN NUMBER;
END DNET$COMMUNITY;
/


GRANT EXECUTE ON USS_VISIT.DNET$COMMUNITY TO II01RC_USS_VISIT_SVC
/

GRANT EXECUTE ON USS_VISIT.DNET$COMMUNITY TO SERVICE_PROXY
/


/* Formatted on 8/12/2025 6:00:01 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_VISIT.DNET$COMMUNITY
IS
    --01.09.2023 Пакет ставить на пром нельзя #88585
    --согласовать с Бондаруком С.
    PROCEDURE RequestLock (p_id IN NUMBER)
    IS
        l_lock_handler   Tools.t_Lockhandler;
    BEGIN
        Ikis_Sys.Ikis_Lock.Request_Lock (
            p_Permanent_Name      => Tools.Ginstance_Lock_Name,
            p_Var_Name            => 'COMVPO_' || TO_CHAR (NVL (p_id, -1)),
            p_Errmessage          =>
                'Паралельна обробка звернення ' || NVL (p_id, -1),
            p_Lockhandler         => l_lock_handler,
            p_Timeout             => 30,
            p_Release_On_Commit   => TRUE);
    END;

    /*function IsAllowProcessed(
      p_ap_id_external in number,
      p_ap_ext_ident number,
      p_comment out varchar2
    ) return number
    is
      l_cnt number(14);
      l_ap_id number(14):= p_ap_id_external;
    begin
      RequestLock(p_ap_ext_ident);
      if l_ap_id is not null then
        select count(1)
          into l_cnt
        from appeal ap
        where ap.ap_tp = 'V'
          and ap.ap_ext_ident = p_ap_ext_ident
          and ap.ap_id = l_ap_id
          and ap.ap_src = 'COM'
          and ap.ap_st = 'VE'
          and exists (select 1 from ap_service aps
            where aps.aps_ap = ap.ap_id and aps.aps_nst = 664
              and aps.history_status = 'A');
        if l_cnt = 1  then
          return 1;
        end if;

        select count(1)
          into l_cnt
        from appeal ap
        where ap.ap_tp = 'V'
          and ap.ap_ext_ident = p_ap_ext_ident
          and ap.ap_id = l_ap_id
          and ap.ap_src = 'DIIA'
          and ap.ap_st in ('VE')
          and not exists (select 1 from ap_service aps
            where aps.aps_ap = ap.ap_id and aps.aps_nst = 664
              and aps.history_status = 'A');

        if l_cnt = 1 then
          return 1;
        end if;
        if l_cnt = 0 then
          p_comment := 'Не знайдено звернення з apId='||l_ap_id||' і id=' ||p_ap_ext_ident || ', або звернення у невідповідному статусі';
          return 0;
        end if;
      end if;

      if l_ap_id is null then
        select count(1)
          into l_cnt
        from appeal ap
        where ap.ap_tp = 'V'
          and ap.ap_ext_ident = p_ap_ext_ident
          and ap.ap_src in ('DIIA', 'COM');
        if l_cnt = 0 then
          return 1;
        else
          return 0;
        end if;
      end if;
      return null;
    exception
      when others then
        raise_application_error(-20000, dbms_utility.format_error_stack || dbms_utility.format_error_backtrace);
    end;*/

    FUNCTION GetApByAps (p_aps_id IN NUMBER, p_aps_nst IN NUMBER)
        RETURN NUMBER
    IS
        l_ap_id   NUMBER (14);
    BEGIN
        SELECT aps.aps_ap
          INTO l_ap_id
          FROM ap_service aps
         WHERE     aps.aps_id = p_aps_id
               AND aps.aps_nst = p_aps_nst
               AND aps.history_status = 'A';

        RETURN l_ap_id;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            RETURN NULL;
    END;

    FUNCTION GetApsByAp (p_ap_id IN NUMBER, p_aps_nst IN NUMBER)
        RETURN NUMBER
    IS
        l_aps_id   NUMBER (14);
    BEGIN
        SELECT MAX (aps.aps_id)
          INTO l_aps_id
          FROM ap_service aps
         WHERE     aps.aps_ap = p_ap_id
               AND aps.aps_nst = p_aps_nst
               AND aps.history_status = 'A';

        RETURN l_aps_id;
    END;

    /*function IsAllowProcessed(
      p_ap_id in number,
      p_ap_ext_ident2 number,
      p_aps_id in number,
      p_comment out varchar2
    ) return number
    is
      l_cnt number(14);
      l_ap_id number(14):= p_ap_id;
      l_ap_is_ext_process appeal.ap_is_ext_process%type;
    begin
      RequestLock(p_ap_ext_ident2);
      if p_aps_id is not null then  --20220901

        --звернення від дії
        select max(ap.ap_is_ext_process)
          into l_ap_is_ext_process
        from appeal ap
        where ap.ap_tp in ('V', 'VPO')
          and ap.ap_id = l_ap_id
          and ap.ap_src = 'DIIA';

        --дозволяється збереження заяви с джерелом Дія, якщо встановлено ознаку "Завнішня обробка"
        --(після першого збереження від СГ ознака переходить в F)
        if l_ap_is_ext_process = 'T' then
          return 1;
        end if;

        --забороняємо повторне збереження заяви від СГ з джерелом Дія
        if l_ap_is_ext_process = 'F' then
          p_comment := 'Збереження звернення від Дії в поточному статусі заборонено';
          return 0;
        end if;

        --тут наш ід + ід СГ
        select count(1)
          into l_cnt
        from appeal ap
        where ap.ap_tp = 'V'
          and ap.ap_ext_ident2 = p_ap_ext_ident2
          and ap.ap_id = l_ap_id
          and ap.ap_src = 'COM'
          and ap.ap_st in ('VE', 'W')
          and exists (select 1 from ap_service aps
            where aps.aps_ap = ap.ap_id and aps.aps_nst = 664
              and aps.history_status = 'A');
        if l_cnt = 1 then
          return 1;
        end if;

        if l_cnt = 0 then
          --Важно помнить apId для СГ это apsId
          p_comment := 'Не знайдено звернення з apId='||p_aps_id||' і id=' ||p_ap_ext_ident2 || ', або звернення у невідповідному статусі';
          return 0;
        end if;
      end if;

      if l_ap_id is null and p_aps_id is null  then
        select count(1)
          into l_cnt
        from appeal ap
        where ap.ap_tp = 'V'
          and ap.ap_ext_ident2 = p_ap_ext_ident2
          and ap.ap_src in ('DIIA', 'COM');
        if l_cnt = 0 then
          return 1;
        else
          return 0;
        end if;
      end if;
      return null;
    exception
      when others then
        raise_application_error(-20000, dbms_utility.format_error_stack || dbms_utility.format_error_backtrace);
    end;*/

    FUNCTION ExistAppelCheck (p_ap_id IN NUMBER, p_ap_ext_ident2 IN NUMBER)
        RETURN NUMBER
    IS
        l_res   appeal.ap_ext_ident2%TYPE;
    BEGIN
        BEGIN
            SELECT MAX (ap.ap_id)
              INTO l_res
              FROM appeal ap
             WHERE     ap.ap_ext_ident2 = p_ap_ext_ident2
                   AND ap.ap_src IN ('DIIA', 'COM')
                   AND ap.ap_tp IN ('V')
                   AND ap.ap_id = p_ap_id;
        EXCEPTION
            WHEN OTHERS
            THEN
                NULL;
        END;

        RETURN l_res;
    END;

    FUNCTION GetApIdByExtid (p_ap_ext_id2 IN NUMBER)
        RETURN NUMBER
    IS
        l_res   appeal.ap_ext_ident2%TYPE;
    BEGIN
        BEGIN
            SELECT MAX (ap.ap_id)
              INTO l_res
              FROM appeal ap
             WHERE     ap.ap_ext_ident2 = p_ap_ext_id2
                   AND ap.ap_src IN ('DIIA', 'COM')
                   AND ap.ap_tp = 'V';
        EXCEPTION
            WHEN OTHERS
            THEN
                NULL;
        END;

        RETURN l_res;
    END;

    FUNCTION DecodeRefDocType2Ndt (p_refDocType_id     IN NUMBER := NULL,
                                   p_refDocType_name   IN VARCHAR2 := NULL)
        RETURN NUMBER
    IS
        l_ndt_id   NUMBER (14);
    BEGIN
        l_ndt_id :=
            CASE
                WHEN p_refDocType_id = 1
                THEN
                    6
                WHEN p_refDocType_id = 2
                THEN
                    7
                WHEN p_refDocType_id = 3
                THEN
                    37
                WHEN     p_refDocType_id = 27
                     AND UPPER (p_refDocType_name) LIKE '%ТИМЧАСОВЕ%'
                THEN
                    9
                WHEN p_refDocType_id = 27
                THEN
                    8
                --when p_refDocType_id = 1112 then 201
                WHEN p_refDocType_id = 1151
                THEN
                    684
                WHEN p_refDocType_id = 1156
                THEN
                    37
                WHEN p_refDocType_id = 1157
                THEN
                    37
                ELSE
                    NULL
            END;
        RETURN l_ndt_id;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END;

    FUNCTION DecodeOrg (p_org IN NUMBER, p_type VARCHAR2:= 'COM2VST')
        RETURN NUMBER
    IS
        --l_org_1 varchar2(10);
        --l_org_org number(14);
        l_cnt   PLS_INTEGER := 0;
        l_res   NUMBER (14);
    --l_org_st varchar2(10);
    BEGIN
        IF p_type = 'COM2VST'
        THEN
            BEGIN
                /*if length(p_org) in (3, 4) then
                  l_org_1 := lpad(p_org, 5, '50');
                else
                  l_org_1 := p_org;
                end if;
                select count(1), max(org.ORG_ORG), max(org.ORG_ST)
                  into l_cnt, l_org_org, l_org_st
                from uss_exch.v_ls_opfu_ref org
                where org.org_id = to_number(l_org_1);

                if l_cnt != 1 then
                  l_org_1 := '50000';
                end if;

                if l_cnt = 1 and nvl(l_org_st, 'X') != 'A' then
                  l_org_1 := l_org_org;
                end if;*/
                l_res :=
                    NVL (
                        uss_ndi.Api$dic_Decoding.District2ComOrgV01 (
                            p_org_src   => p_org),
                        50000);

                SELECT COUNT (*)
                  INTO l_cnt
                  FROM ikis_sys.v_opfu org
                 WHERE org.org_id = l_res AND org.org_st = 'A';

                IF l_cnt != 1
                THEN
                    --l_res := 50000;
                    raise_application_error (-20000,
                                             'Не знайдено район ЄІССС');
                END IF;
            END;

            RETURN l_res;
        END IF;

        RETURN NULL;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END;

    FUNCTION getDbName
        RETURN VARCHAR2
    IS
        l_dbname   VARCHAR2 (1000);
    BEGIN
        SELECT UPPER (SYS_CONTEXT ('USERENV', 'DB_NAME'))
          INTO l_dbname
          FROM DUAL;

        RETURN l_dbname;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN NULL;
    END;

    FUNCTION CheckAppealTest1 (p_ap_id IN NUMBER)
        RETURN PLS_INTEGER
    IS
        l_res        PLS_INTEGER := 0;
        l_ap_src     appeal.ap_src%TYPE;
        l_dt         DATE;
        l_dt_test1   DATE := TO_DATE ('04.08.2022', 'dd.mm.yyyy');
    --l_ap_src varchar2(100);
    BEGIN
        SELECT ap.ap_src, TRUNC (ap.ap_create_dt, 'DD')
          INTO l_ap_src, l_dt
          FROM appeal ap
         WHERE ap.ap_id = p_ap_id;

        IF l_ap_src = 'DIIA' AND l_dt = l_dt_test1
        THEN
            RETURN 1;
        END IF;

        RETURN 0;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN 0;
    END;

    PROCEDURE ChangeAppealTypeVpo2V (p_ap_id IN NUMBER, p_ap_src IN VARCHAR2)
    IS
        l_Ap_src_c   appeal.ap_src%TYPE;
        l_ap_tp_c    appeal.ap_tp%TYPE;
    BEGIN
        l_Ap_src_c := Api$appeal.Get_Ap_Src (p_Ap_Id => p_Ap_Id);
        l_ap_tp_c := Api$appeal.Get_Ap_Tp (p_Ap_Id => p_Ap_Id);

        IF l_Ap_src_c = 'DIIA' AND l_ap_tp_c = 'VPO' AND p_ap_src = 'COM'
        THEN
            Api$appeal.Set_Ap_Tp (p_Ap_Id => p_ap_id, p_Ap_Tp => 'V');
        END IF;
    END;

    PROCEDURE SetAppealExtIdent2 (p_ap_id           IN NUMBER,
                                  p_ap_ext_ident2   IN NUMBER)
    IS
        l_Ap_src_c          appeal.ap_src%TYPE;
        l_ap_tp_c           appeal.ap_tp%TYPE;
        l_ap_ext_ident2_c   appeal.ap_ext_ident2%TYPE;
    BEGIN
        l_Ap_src_c := Api$appeal.Get_Ap_Src (p_Ap_Id => p_Ap_Id);
        l_ap_tp_c := Api$appeal.Get_Ap_Tp (p_Ap_Id => p_Ap_Id);
        l_ap_ext_ident2_c := Api$appeal.Get_Ap_Ext_Ident2 (p_Ap_Id => p_ap_id);

        IF     l_Ap_src_c = 'DIIA'
           AND l_ap_tp_c IN ('VPO', 'V')
           AND l_ap_ext_ident2_c IS NULL
        THEN
            Api$appeal.Set_Ap_Ext_Ident2 (
                p_Ap_Id           => p_ap_id,
                p_ap_ext_ident2   => p_ap_ext_ident2);
        END IF;
    END;

    --20220520
    --Обмін з ПК Соціальна громада реєстрація звернень ВПО щодо допомоги на проживання ПКМУ 332 в ЄІССС для подальшого опрацювання
    --#77252
    PROCEDURE Save_Appeal (p_ap_id               IN     NUMBER,
                           p_new_id                 OUT NUMBER,
                           p_ap_num              IN     VARCHAR2,
                           p_ap_reg_dt           IN     DATE,
                           p_rn_id               IN     NUMBER,
                           p_ap_ext_ident        IN     NUMBER,
                           p_ap_src              IN     VARCHAR2,
                           p_com_org             IN     NUMBER,
                           p_Ap_Is_Second        IN     VARCHAR2 := 'F',
                           p_Ap_Is_Ext_Process   IN     VARCHAR2 := 'F',
                           p_Ap_Tp               IN     VARCHAR2,
                           p_ap_ext_ident2       IN     NUMBER)
    IS
        l_Ap_St   appeal.ap_st%TYPE := Api$appeal.c_Ap_St_Reg; --Api$appeal.c_Ap_St_Reg_In_Work;
        l_ap_id   NUMBER;
        --l_aps_id number;
        l_hs_id   NUMBER (14);
    BEGIN
        --tools.WriteMsg('DNET$COMMUNITY.'||$$PLSQL_UNIT);
        IF     p_Ap_Id BETWEEN 6435 AND 3389653
           AND NVL (getDbName (), '~') = 'USSTEST1'
        THEN
            IF CheckAppealTest1 (p_Ap_Id) = 1
            THEN
                l_Ap_St := 'N';
            END IF;
        END IF;

        IF p_Ap_Id > 0
        THEN
            IF Api$appeal.Get_Ap_Src (p_Ap_Id => p_Ap_Id) = 'DIIA'
            THEN
                ChangeAppealTypeVpo2V (p_ap_id, p_ap_src);
                SetAppealExtIdent2 (p_ap_id, p_ap_ext_ident2);
            END IF;
        END IF;

        Api$appeal.Save_Appeal (p_Ap_Id               => p_Ap_Id,
                                p_Ap_Num              => p_Ap_Num,
                                p_Ap_Reg_Dt           => p_Ap_Reg_Dt,
                                p_Ap_Create_Dt        => SYSDATE,
                                p_Ap_Src              => p_ap_src,
                                p_Ap_St               => l_ap_st,
                                p_Com_Org             => p_com_org,
                                p_Ap_Dest_Org         => p_com_org,
                                p_Ap_Is_Second        => p_Ap_Is_Second,
                                p_Ap_Vf               => NULL,
                                p_Com_Wu              => NULL,
                                p_Ap_Tp               => p_Ap_Tp, --Api$appeal.c_Ap_Tp_Help, --V тип
                                p_New_Id              => p_new_id,
                                p_Ap_Ext_Ident        => p_Ap_Ext_Ident,
                                p_Ap_Doc              => NULL,
                                p_Ap_Is_Ext_Process   => p_Ap_Is_Ext_Process,
                                p_Obi_Ts              => NULL,
                                p_Ap_Ext_Ident2       => p_ap_ext_ident2);
        l_ap_id := p_new_id;

        Ikis_Rbm.Api$request.Save_Rn_Common_Info (p_Rnc_Rn       => p_Rn_Id,
                                                  p_Rnc_Pt       => 209,
                                                  p_Rnc_Val_Id   => l_ap_id);
        l_Hs_Id := Tools.Gethistsession ();
        Api$appeal.Write_Log (
            p_Apl_Ap   => l_ap_id,
            p_Apl_Hs   => l_Hs_Id,
            p_Apl_St   => l_Ap_St,
            p_Apl_Message   =>
                CASE
                    WHEN p_Ap_Id IS NULL THEN CHR (38) || '1'
                    ELSE CHR (38) || '2'
                END);

        IF p_Ap_Id > 0
        THEN
            --очищення зверннення
            SetAllApealDocumentToHistory (p_Ap_Id);
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END;

    PROCEDURE ChangeStatusAppelDiia (p_ap_id IN NUMBER)
    IS
        l_hs_id   NUMBER (14);
        l_Ap_St   appeal.ap_st%TYPE := Api$appeal.c_Ap_St_Reg;
    BEGIN
        UPDATE Uss_Visit.appeal ap
           SET ap.ap_st = l_Ap_St
         WHERE ap.ap_id = p_ap_id;

        l_Hs_Id := Tools.Gethistsession ();
        Api$appeal.Write_Log (p_Apl_Ap        => p_ap_id,
                              p_Apl_Hs        => l_Hs_Id,
                              p_Apl_St        => l_Ap_St,
                              p_Apl_Message   => CHR (38) || '2');
    END;

    PROCEDURE ChangeOrgAppelDiia (p_ap_id IN NUMBER, p_org IN NUMBER)
    IS
    BEGIN
        UPDATE Uss_Visit.appeal ap
           SET ap.com_org = p_org
         WHERE ap.ap_id = p_ap_id;
    END;

    PROCEDURE Save_Service (p_Aps_Id    IN     NUMBER,
                            p_new_id       OUT NUMBER,
                            p_Aps_Nst   IN     NUMBER,
                            p_Aps_Ap    IN     NUMBER,
                            p_Aps_St    IN     VARCHAR2)
    IS
        l_pre_aps_id   NUMBER (14);
    BEGIN
        Api$appeal.Save_Service (p_Aps_Id    => p_Aps_Id,
                                 p_Aps_Nst   => p_Aps_Nst,        --#77252 664
                                 p_Aps_Ap    => p_Aps_Ap,
                                 p_Aps_St    => p_Aps_St, --uss_ndi.v_ddn_aps_st R
                                 p_New_Id    => p_new_id);
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END;

    PROCEDURE Save_Person (
        p_App_Id        IN     Ap_Person.App_Id%TYPE := NULL,
        p_App_Ap        IN     Ap_Person.App_Ap%TYPE := NULL,
        p_App_Tp        IN     Ap_Person.App_Tp%TYPE := NULL,
        p_App_Inn       IN     Ap_Person.App_Inn%TYPE := NULL,
        p_App_Ndt       IN     Ap_Person.App_Ndt%TYPE := NULL,
        p_App_Doc_Num   IN     Ap_Person.App_Doc_Num%TYPE := NULL,
        p_App_Fn        IN     Ap_Person.App_Fn%TYPE := NULL,
        p_App_Mn        IN     Ap_Person.App_Mn%TYPE := NULL,
        p_App_Ln        IN     Ap_Person.App_Ln%TYPE := NULL,
        p_App_Esr_Num   IN     Ap_Person.App_Esr_Num%TYPE := NULL,
        p_Gender        IN     Ap_Person.App_Gender%TYPE := NULL,
        p_App_Vf        IN     Ap_Person.App_Vf%TYPE := NULL,
        p_App_Sc        IN     Ap_Person.App_Sc%TYPE := NULL,
        p_New_Id           OUT Ap_Person.App_Id%TYPE)
    IS
    BEGIN
        Api$appeal.Save_Person (p_App_Id        => NULL,           --p_App_Id,
                                p_App_Ap        => p_App_Ap,
                                p_App_Tp        => p_App_Tp,
                                p_App_Inn       => p_App_Inn,
                                p_App_Ndt       => p_App_Ndt,
                                p_App_Doc_Num   => p_App_Doc_Num,
                                p_App_Fn        => p_App_Fn,
                                p_App_Mn        => p_App_Mn,
                                p_App_Ln        => p_App_Ln,
                                p_App_Esr_Num   => p_App_Esr_Num,
                                p_App_Gender    => p_Gender,
                                p_App_Vf        => NULL,
                                p_App_Sc        => p_App_Sc,
                                p_App_Num       => NULL,
                                p_New_Id        => p_New_Id);
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END;

    PROCEDURE Save_Person_Doc (p_apd_id    IN     NUMBER,
                               p_new_id       OUT NUMBER,
                               p_apd_ap    IN     NUMBER,
                               p_apd_ndt   IN     NUMBER,
                               p_Apd_Doc   IN     NUMBER,
                               p_apd_app   IN     NUMBER,
                               p_Apd_Dh    IN     NUMBER,
                               p_Apd_Aps   IN     NUMBER,
                               p_Apd_Src   IN     VARCHAR2 := 'COM')
    IS
    --l_apd_ndt number(14);
    BEGIN
        Api$appeal.Save_Document (p_Apd_Id    => p_apd_id,
                                  p_Apd_Ap    => p_apd_ap,
                                  p_Apd_Ndt   => p_apd_ndt,
                                  p_Apd_Doc   => p_Apd_Doc,                --?
                                  p_Apd_Vf    => NULL,
                                  p_Apd_App   => p_apd_app,
                                  p_New_Id    => p_new_id,
                                  p_Com_Wu    => NULL,
                                  p_Apd_Dh    => p_Apd_Dh,
                                  p_Apd_Src   => p_Apd_Src,
                                  p_Apd_Aps   => p_Apd_Aps);
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END;

    PROCEDURE Save_Attributes_Doc (
        p_Apda_Id           IN     Ap_Document_Attr.Apda_Id%TYPE,
        p_Apda_Ap           IN     Ap_Document_Attr.Apda_Ap%TYPE,
        p_Apda_Apd          IN     Ap_Document_Attr.Apda_Apd%TYPE,
        p_Apda_Nda          IN     Ap_Document_Attr.Apda_Nda%TYPE,
        p_New_Id               OUT Ap_Document_Attr.Apda_Val_Id%TYPE,
        p_Apda_Val_Int      IN     Ap_Document_Attr.Apda_Val_Int%TYPE := NULL,
        p_Apda_Val_Dt       IN     Ap_Document_Attr.Apda_Val_Dt%TYPE := NULL,
        p_Apda_Val_String   IN     Ap_Document_Attr.Apda_Val_String%TYPE := NULL,
        p_Apda_Val_Id       IN     Ap_Document_Attr.Apda_Val_Id%TYPE := NULL,
        p_Apda_Val_Sum      IN     Ap_Document_Attr.Apda_Val_Sum%TYPE := NULL)
    IS
        l_res   NUMBER (14);
    BEGIN
        Api$appeal.Save_Document_Attr (
            p_Apda_Id           => p_Apda_Id,
            p_Apda_Ap           => p_Apda_Ap,
            p_Apda_Apd          => p_Apda_Apd,
            p_Apda_Nda          => p_Apda_Nda,
            p_Apda_Val_Int      => p_Apda_Val_Int,
            p_Apda_Val_Dt       => p_Apda_Val_Dt,
            p_Apda_Val_String   => p_Apda_Val_String,
            p_Apda_Val_Id       => p_Apda_Val_Id,
            p_Apda_Val_Sum      => p_Apda_Val_Sum,
            p_New_Id            => l_res);
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END;

    PROCEDURE Save_Person_Doc_Attribute (p_Ap_id        IN     NUMBER,
                                         p_New_Id          OUT NUMBER,
                                         p_Apd_id       IN     NUMBER,
                                         p_Ndt_id       IN     NUMBER,
                                         p_Doc_Serial   IN     VARCHAR2,
                                         p_Doc_Number   IN     VARCHAR2,
                                         p_Authority    IN     VARCHAR2,
                                         p_Start        IN     DATE,
                                         p_Expired      IN     DATE,
                                         p_Unzr         IN     NUMBER,
                                         p_Birth_Dt     IN     DATE)
    IS
        l_New_Id   NUMBER (14);
    BEGIN
        --todo: перевірити навіщо зберігаються атрибути для документа 684, з урахуванням того, що для цього типу немає атрибутів в довіднику
        IF     (p_Doc_Serial || p_Doc_Number) IS NOT NULL
           AND p_Ndt_id IN (6,
                            7,
                            8,
                            9,
                            37,
                            684)
        THEN
            Api$appeal.Save_Document_Attr (
                p_Apda_Id           => NULL,
                p_Apda_Ap           => p_Ap_id,
                p_Apda_Apd          => p_Apd_id,
                p_Apda_Nda          =>
                    CASE
                        WHEN p_Ndt_id = 6 THEN 3
                        WHEN p_Ndt_id = 7 THEN 9
                        WHEN p_Ndt_id = 8 THEN 15
                        WHEN p_Ndt_id = 9 THEN 21
                        WHEN p_Ndt_id = 37 THEN 90
                        WHEN p_Ndt_id = 684 THEN NULL
                        ELSE NULL
                    END,
                p_Apda_Val_Int      => NULL,
                p_Apda_Val_Dt       => NULL,
                p_Apda_Val_String   =>
                    CASE
                        WHEN p_Ndt_id IN (7, 684) THEN p_Doc_Number
                        ELSE p_Doc_Serial || p_Doc_Number
                    END,
                p_Apda_Val_Id       => NULL,
                p_Apda_Val_Sum      => NULL,
                p_New_Id            => l_New_Id);

            IF p_Ndt_id IN (7)
            THEN
                Api$appeal.Save_Document_Attr (
                    p_Apda_Id           => NULL,
                    p_Apda_Ap           => p_Ap_id,
                    p_Apda_Apd          => p_Apd_id,
                    p_Apda_Nda          => 810,
                    p_Apda_Val_Int      => NULL,
                    p_Apda_Val_Dt       => NULL,
                    p_Apda_Val_String   => p_Unzr,
                    p_Apda_Val_Id       => NULL,
                    p_Apda_Val_Sum      => NULL,
                    p_New_Id            => l_New_Id);
            END IF;
        END IF;

        --authority
        IF     p_Authority IS NOT NULL
           AND p_Ndt_id IN (6,
                            7,
                            8,
                            9,
                            37,
                            684)
        THEN
            Api$appeal.Save_Document_Attr (
                p_Apda_Id           => NULL,
                p_Apda_Ap           => p_Ap_id,
                p_Apda_Apd          => p_Apd_id,
                p_Apda_Nda          =>
                    CASE
                        WHEN p_Ndt_id = 6 THEN 7
                        WHEN p_Ndt_id = 7 THEN 13
                        WHEN p_Ndt_id = 8 THEN 17
                        WHEN p_Ndt_id = 9 THEN 23
                        WHEN p_Ndt_id = 37 THEN 93
                        WHEN p_Ndt_id = 684 THEN NULL
                        ELSE NULL
                    END,
                p_Apda_Val_Int      => NULL,
                p_Apda_Val_Dt       => NULL,
                p_Apda_Val_String   => p_Authority,
                p_Apda_Val_Id       => NULL,
                p_Apda_Val_Sum      => NULL,
                p_New_Id            => l_New_Id);
        END IF;

        --start
        IF     p_Start IS NOT NULL
           AND p_Ndt_id IN (6,
                            7,
                            8,
                            9,
                            37,
                            684)
        THEN
            Api$appeal.Save_Document_Attr (
                p_Apda_Id           => NULL,
                p_Apda_Ap           => p_Ap_id,
                p_Apda_Apd          => p_Apd_id,
                p_Apda_Nda          =>
                    CASE
                        WHEN p_Ndt_id = 6 THEN 5
                        WHEN p_Ndt_id = 7 THEN 14
                        WHEN p_Ndt_id = 8 THEN 20
                        WHEN p_Ndt_id = 9 THEN 22
                        WHEN p_Ndt_id = 37 THEN 94
                        WHEN p_Ndt_id = 684 THEN NULL
                        ELSE NULL
                    END,
                p_Apda_Val_Int      => NULL,
                p_Apda_Val_Dt       => p_Start,
                p_Apda_Val_String   => NULL,
                p_Apda_Val_Id       => NULL,
                p_Apda_Val_Sum      => NULL,
                p_New_Id            => l_New_Id);
        END IF;

        --expired
        IF     p_Expired IS NOT NULL
           AND p_Ndt_id IN (6,
                            7,
                            8,
                            9,
                            37,
                            684)
        THEN
            Api$appeal.Save_Document_Attr (
                p_Apda_Id           => NULL,
                p_Apda_Ap           => p_Ap_id,
                p_Apda_Apd          => p_Apd_id,
                p_Apda_Nda          =>
                    CASE
                        WHEN p_Ndt_id = 6 THEN 6
                        WHEN p_Ndt_id = 7 THEN 10
                        WHEN p_Ndt_id = 8 THEN 19
                        WHEN p_Ndt_id = 9 THEN 24
                        WHEN p_Ndt_id = 37 THEN NULL
                        WHEN p_Ndt_id = 684 THEN NULL
                        ELSE NULL
                    END,
                p_Apda_Val_Int      => NULL,
                p_Apda_Val_Dt       => p_Expired,
                p_Apda_Val_String   => NULL,
                p_Apda_Val_Id       => NULL,
                p_Apda_Val_Sum      => NULL,
                p_New_Id            => l_New_Id);
        END IF;

        IF     p_Birth_Dt IS NOT NULL
           AND p_Ndt_id IN (6,
                            7,
                            8,
                            9,
                            37,
                            684)
        THEN
            Api$appeal.Save_Document_Attr (
                p_Apda_Id           => NULL,
                p_Apda_Ap           => p_Ap_id,
                p_Apda_Apd          => p_Apd_id,
                p_Apda_Nda          =>
                    CASE
                        WHEN p_Ndt_id = 6 THEN 606
                        WHEN p_Ndt_id = 7 THEN 607
                        WHEN p_Ndt_id = 8 THEN NULL
                        WHEN p_Ndt_id = 9 THEN NULL
                        WHEN p_Ndt_id = 37 THEN 91
                        WHEN p_Ndt_id = 684 THEN NULL
                        ELSE NULL
                    END,
                p_Apda_Val_Int      => NULL,
                p_Apda_Val_Dt       => p_Birth_Dt,
                p_Apda_Val_String   => NULL,
                p_Apda_Val_Id       => NULL,
                p_Apda_Val_Sum      => NULL,
                p_New_Id            => l_New_Id);
        END IF;

        --shost 28102022: додано збереження атрибутів ПІБ для проходження верифікації документів що посвідчують особо
        DECLARE
            l_App_Ln   Ap_Person.App_Ln%TYPE;
            l_App_Fn   Ap_Person.App_Fn%TYPE;
            l_App_Mn   Ap_Person.App_Mn%TYPE;
        BEGIN
            SELECT p.App_Ln, p.App_Fn, p.App_Mn
              INTO l_App_Ln, l_App_Fn, l_App_Mn
              FROM Ap_Document d JOIN Ap_Person p ON d.Apd_App = p.App_Id
             WHERE d.Apd_Id = p_Apd_Id;

            IF l_App_Ln IS NOT NULL AND l_App_Fn IS NOT NULL
            THEN
                IF p_Ndt_Id IN (37)
                THEN
                    Api$appeal.Save_Document_Attr (
                        p_Apda_Id           => NULL,
                        p_Apda_Ap           => p_Ap_Id,
                        p_Apda_Apd          => p_Apd_Id,
                        p_Apda_Nda          => 92,
                        p_Apda_Val_Int      => NULL,
                        p_Apda_Val_Dt       => NULL,
                        p_Apda_Val_String   =>
                            Pib (l_App_Ln, l_App_Fn, l_App_Mn),
                        p_Apda_Val_Id       => NULL,
                        p_Apda_Val_Sum      => NULL,
                        p_New_Id            => l_New_Id);
                ELSIF p_Ndt_Id IN (6,
                                   7,
                                   8,
                                   9)
                THEN
                    Api$appeal.Save_Document_Attr (
                        p_Apda_Id           => NULL,
                        p_Apda_Ap           => p_Ap_Id,
                        p_Apda_Apd          => p_Apd_Id,
                        p_Apda_Nda          =>
                            CASE
                                WHEN p_Ndt_Id = 6 THEN 2375
                                WHEN p_Ndt_Id = 7 THEN 2376
                                WHEN p_Ndt_Id = 8 THEN 2379
                                WHEN p_Ndt_Id = 9 THEN 2382
                            END,
                        p_Apda_Val_Int      => NULL,
                        p_Apda_Val_Dt       => NULL,
                        p_Apda_Val_String   => l_App_Ln,
                        p_Apda_Val_Id       => NULL,
                        p_Apda_Val_Sum      => NULL,
                        p_New_Id            => l_New_Id);

                    Api$appeal.Save_Document_Attr (
                        p_Apda_Id           => NULL,
                        p_Apda_Ap           => p_Ap_Id,
                        p_Apda_Apd          => p_Apd_Id,
                        p_Apda_Nda          =>
                            CASE
                                WHEN p_Ndt_Id = 6 THEN 2374
                                WHEN p_Ndt_Id = 7 THEN 2377
                                WHEN p_Ndt_Id = 8 THEN 2380
                                WHEN p_Ndt_Id = 9 THEN 2383
                            END,
                        p_Apda_Val_Int      => NULL,
                        p_Apda_Val_Dt       => NULL,
                        p_Apda_Val_String   => l_App_Fn,
                        p_Apda_Val_Id       => NULL,
                        p_Apda_Val_Sum      => NULL,
                        p_New_Id            => l_New_Id);

                    Api$appeal.Save_Document_Attr (
                        p_Apda_Id           => NULL,
                        p_Apda_Ap           => p_Ap_Id,
                        p_Apda_Apd          => p_Apd_Id,
                        p_Apda_Nda          =>
                            CASE
                                WHEN p_Ndt_Id = 6 THEN 2373
                                WHEN p_Ndt_Id = 7 THEN 2378
                                WHEN p_Ndt_Id = 8 THEN 2381
                                WHEN p_Ndt_Id = 9 THEN 2384
                            END,
                        p_Apda_Val_Int      => NULL,
                        p_Apda_Val_Dt       => NULL,
                        p_Apda_Val_String   => l_App_Mn,
                        p_Apda_Val_Id       => NULL,
                        p_Apda_Val_Sum      => NULL,
                        p_New_Id            => l_New_Id);
                END IF;
            END IF;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                NULL;
        END;

        IF p_Unzr IS NOT NULL AND p_Ndt_id IN (37)
        THEN
            Api$appeal.Save_Document_Attr (p_Apda_Id           => NULL,
                                           p_Apda_Ap           => p_Ap_id,
                                           p_Apda_Apd          => p_Apd_id,
                                           p_Apda_Nda          => 870,
                                           p_Apda_Val_Int      => NULL,
                                           p_Apda_Val_Dt       => NULL,
                                           p_Apda_Val_String   => p_Unzr,
                                           p_Apda_Val_Id       => NULL,
                                           p_Apda_Val_Sum      => NULL,
                                           p_New_Id            => l_New_Id);
        END IF;

        IF p_Ndt_id IN (5)
        THEN
            Api$appeal.Save_Document_Attr (
                p_Apda_Id           => NULL,
                p_Apda_Ap           => p_Ap_id,
                p_Apda_Apd          => p_Apd_id,
                p_Apda_Nda          => 1,
                p_Apda_Val_Int      => NULL,
                p_Apda_Val_Dt       => NULL,
                p_Apda_Val_String   => p_Doc_Number,
                p_Apda_Val_Id       => NULL,
                p_Apda_Val_Sum      => NULL,
                p_New_Id            => l_New_Id);
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END;

    PROCEDURE Decode_Dic_Value (p_Nddc_Tp         IN     VARCHAR2,
                                p_Nddc_Src        IN     VARCHAR2,
                                p_Nddc_Dest       IN     VARCHAR2,
                                p_Nddc_Code_Src   IN     VARCHAR2,
                                p_out                OUT VARCHAR2)
    IS
    BEGIN
        p_out :=
            uss_ndi.TOOLS.Decode_Dict (p_Nddc_Tp         => p_Nddc_Tp,
                                       p_Nddc_Src        => p_Nddc_Src,
                                       p_Nddc_Dest       => p_Nddc_Dest,
                                       p_Nddc_Code_Src   => p_Nddc_Code_Src);
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   SQLERRM
                || ' '
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END;

    PROCEDURE Set_Person_ScId (p_apd_id    IN     NUMBER,
                               p_ap_id     IN     NUMBER,
                               p_date      IN     DATE,
                               p_sc_id        OUT NUMBER,
                               p_esr_num      OUT VARCHAR2)
    IS
        l_ap_person   ap_person%ROWTYPE;
        l_birth_dt    DATE;
    BEGIN
        SELECT *
          INTO l_ap_person
          FROM ap_person app
         WHERE app.app_id = p_apd_id AND app.app_ap = p_ap_id;

        SELECT MIN (apda.apda_val_dt)
          INTO l_birth_dt
          FROM ap_document_attr apda, ap_document apd
         WHERE     apda.apda_ap = p_ap_id
               AND apda.apda_apd = apd.apd_id
               AND apd.apd_ap = apda.apda_ap
               AND apd.apd_app = l_ap_person.app_id
               AND apda.history_status = 'A'
               AND apd.history_status = 'A'
               AND apda.apda_nda IN (606, 607, 91);

        l_ap_person.app_sc :=
            uss_person.Load$socialcard.Load_SC (
                p_fn            => l_ap_person.app_fn,
                p_ln            => l_ap_person.app_ln,
                p_mn            => l_ap_person.app_mn,
                p_gender        => l_ap_person.app_gender,
                p_nationality   => NULL,
                p_src_dt        => p_date,
                p_birth_dt      => l_birth_dt,
                p_inn_num       => l_ap_person.app_inn,
                p_inn_ndt       =>
                    CASE
                        WHEN l_ap_person.app_inn IS NOT NULL THEN 5
                        ELSE NULL
                    END,
                p_doc_ser       => NULL,
                p_doc_num       => l_ap_person.app_doc_num,
                p_doc_ndt       => l_ap_person.app_ndt,
                p_src           => 'COM',
                p_sc_unique     => p_esr_num,
                p_sc            => l_ap_person.app_sc);
        p_sc_id := l_ap_person.app_sc;

        --не знаю на сколько правильно просто определять параметры до вставки особы наверно не нужно
        UPDATE ap_person app
           SET app.app_sc = p_sc_id, app.app_esr_num = p_esr_num
         WHERE app.app_id = p_apd_id AND app.app_ap = p_ap_id;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END;


    PROCEDURE Load_socialcard (p_sc_id            OUT NUMBER,
                               p_sc_unique        OUT VARCHAR2,
                               p_fn            IN     VARCHAR2,
                               p_ln            IN     VARCHAR2,
                               p_mn            IN     VARCHAR2,
                               p_gender        IN     VARCHAR2,
                               p_nationality   IN     VARCHAR2,
                               p_src_dt        IN     DATE,
                               p_birth_dt      IN     DATE,
                               p_inn_num       IN     VARCHAR2,
                               p_inn_ndt       IN     NUMBER,
                               p_doc_ser       IN     VARCHAR2,
                               p_doc_num       IN     VARCHAR2,
                               p_doc_ndt       IN     NUMBER,
                               p_src           IN     VARCHAR2)
    IS
    --l_sc_id number(14);
    BEGIN
        p_sc_id :=
            uss_person.Load$socialcard.Load_SC (
                p_fn            => p_fn,
                p_ln            => p_ln,
                p_mn            => p_mn,
                p_gender        => p_gender,
                p_nationality   => p_nationality,
                p_src_dt        => p_src_dt,
                p_birth_dt      => p_birth_dt,
                p_inn_num       => p_inn_num,
                p_inn_ndt       => p_inn_ndt,
                p_doc_ser       => p_doc_ser,
                p_doc_num       => p_doc_num,
                p_doc_ndt       => p_doc_ndt,
                p_src           => p_src,
                p_sc_unique     => p_sc_unique,
                p_sc            => p_sc_id);
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END;

    PROCEDURE GetDictionaryId (p_dict_name   IN     VARCHAR2,
                               p_id             OUT NUMBER,
                               p_code01             VARCHAR2,
                               p_code02             VARCHAR2 := NULL,
                               p_code03             NUMBER := NULL)
    IS
    BEGIN
        IF p_dict_name = 'KATOTTG'
        THEN
            BEGIN
                SELECT d.kaot_id
                  INTO p_id
                  FROM uss_ndi.v_ndi_katottg d
                 WHERE d.kaot_code = p_code01;
            EXCEPTION
                WHEN OTHERS
                THEN
                    p_id := NULL;
            END;
        ELSIF p_dict_name = 'POSTINDEX'
        THEN
            BEGIN
                SELECT d.npo_id
                  INTO p_id
                  FROM uss_ndi.v_ndi_post_office d
                 WHERE d.npo_index = p_code01;
            EXCEPTION
                WHEN OTHERS
                THEN
                    p_id := NULL;
            END;
        ELSIF p_dict_name = 'STREET'
        THEN
            BEGIN
                SELECT d.ns_id
                  INTO p_id
                  FROM uss_ndi.v_Ndi_Street d
                 WHERE d.ns_code = p_code01 AND d.ns_org = p_code03;
            EXCEPTION
                WHEN OTHERS
                THEN
                    p_id := NULL;
            END;
        ELSIF p_dict_name = 'BANK'
        THEN
            BEGIN
                SELECT d.nb_id
                  INTO p_id
                  FROM uss_ndi.v_ndi_bank d
                 WHERE d.nb_mfo = p_code01 AND d.history_status = 'A';
            EXCEPTION
                WHEN OTHERS
                THEN
                    p_id := NULL;
            END;
        ELSE
            NULL;
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END;

    PROCEDURE GetDictionaryStr (p_id      IN     VARCHAR2,
                                p_code    IN     VARCHAR2,
                                p_value      OUT VARCHAR2)
    IS
    BEGIN
        IF p_code = 'KATOTTGTXT'
        THEN
            BEGIN
                --select d.kaot_full_name into p_value from uss_ndi.v_ndi_katottg d where d.kaot_id = p_id;

                SELECT TRIM (
                              d1
                           || CASE WHEN d2 IS NOT NULL THEN ', ' ELSE '' END
                           || d2
                           || CASE WHEN d3 IS NOT NULL THEN ', ' ELSE '' END
                           || d3
                           || CASE WHEN d4 IS NOT NULL THEN ', ' ELSE '' END
                           || d4
                           || CASE WHEN d5 IS NOT NULL THEN ', ' ELSE '' END
                           || d5)
                  INTO p_value
                  FROM (SELECT CASE
                                   WHEN a.d1 IS NOT NULL THEN a.d1
                                   ELSE NULL
                               END    d1,
                               CASE
                                   WHEN NVL (a.d2, -1) != NVL (a.d1, -1)
                                   THEN
                                       a.d2
                                   ELSE
                                       NULL
                               END    d2,
                               CASE
                                   WHEN NVL (a.d3, -1) != NVL (a.d2, -1)
                                   THEN
                                       a.d3
                                   ELSE
                                       NULL
                               END    d3,
                               CASE
                                   WHEN NVL (a.d4, -1) != NVL (a.d3, -1)
                                   THEN
                                       a.d4
                                   ELSE
                                       NULL
                               END    d4,
                               CASE
                                   WHEN NVL (a.d5, -1) != NVL (a.d4, -1)
                                   THEN
                                       a.d5
                                   ELSE
                                       NULL
                               END    d5
                          FROM (SELECT (SELECT d1.kaot_full_name
                                          FROM uss_ndi.v_ndi_katottg d1
                                         WHERE d1.kaot_id = d.kaot_kaot_l1)
                                           d1,
                                       (SELECT d2.kaot_full_name
                                          FROM uss_ndi.v_ndi_katottg d2
                                         WHERE d2.kaot_id = d.kaot_kaot_l2)
                                           d2,
                                       (SELECT d3.kaot_full_name
                                          FROM uss_ndi.v_ndi_katottg d3
                                         WHERE d3.kaot_id = d.kaot_kaot_l3)
                                           d3,
                                       (SELECT d4.kaot_full_name
                                          FROM uss_ndi.v_ndi_katottg d4
                                         WHERE d4.kaot_id = d.kaot_kaot_l4)
                                           d4,
                                       (SELECT d5.kaot_full_name
                                          FROM uss_ndi.v_ndi_katottg d5
                                         WHERE d5.kaot_id = d.kaot_kaot_l5)
                                           d5
                                  FROM uss_ndi.v_ndi_katottg d
                                 WHERE d.kaot_id = p_id) a);
            /*
            select trim(res)
              into p_value
            from (
              select listagg(kaot_full_name,', ') within group(order by lv desc) res
              from (
                select level lv, d.kaot_full_name
                from uss_ndi.v_ndi_katottg d
                connect by nocycle prior coalesce(
                  case when d.kaot_kaot_l5 =  d.kaot_id then null else d.kaot_kaot_l5 end,
                  case when d.kaot_kaot_l4 =  d.kaot_id then null else d.kaot_kaot_l4 end,
                  case when d.kaot_kaot_l3 =  d.kaot_id then null else d.kaot_kaot_l3 end,
                  case when d.kaot_kaot_l2 =  d.kaot_id then null else d.kaot_kaot_l2 end,
                  case when d.kaot_kaot_l1 =  d.kaot_id then null else d.kaot_kaot_l1 end
                  ) = d.kaot_id
                start with d.kaot_id = p_id
               )
             );
             */
            EXCEPTION
                WHEN OTHERS
                THEN
                    p_value := NULL;
            END;
        ELSE
            NULL;
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END;

    PROCEDURE Save_Payment (
        p_Apm_Id             IN     ap_payment.apm_id%TYPE,
        p_New_Id                OUT ap_payment.apm_id%TYPE,
        p_Apm_Ap             IN     ap_payment.apm_ap%TYPE,
        p_Apm_Aps            IN     ap_payment.apm_aps%TYPE,
        p_Apm_App            IN     ap_payment.apm_app%TYPE,
        p_Apm_Tp             IN     ap_payment.apm_tp%TYPE,
        p_Apm_Index          IN     ap_payment.apm_index%TYPE := NULL,
        p_Apm_Kaot           IN     ap_payment.apm_kaot%TYPE := NULL,
        p_Apm_Nb             IN     ap_payment.apm_nb%TYPE := NULL,
        p_Apm_Account        IN     ap_payment.apm_account%TYPE,
        p_Apm_Need_Account   IN     ap_payment.apm_need_account%TYPE := NULL,
        p_Apm_Street         IN     ap_payment.apm_street%TYPE := NULL,
        p_Apm_Ns             IN     ap_payment.apm_ns%TYPE := NULL,
        p_Apm_Building       IN     ap_payment.apm_building%TYPE := NULL,
        p_Apm_Block          IN     ap_payment.apm_block%TYPE := NULL,
        p_Apm_Apartment      IN     ap_payment.apm_apartment%TYPE := NULL,
        p_Apm_Dppa           IN     ap_payment.apm_dppa%TYPE := NULL)
    IS
        l_Apm_Nb   NUMBER;
    BEGIN
        IF p_Apm_Nb IS NOT NULL
        THEN
            l_Apm_Nb := p_Apm_Nb;
        ELSIF p_Apm_Account IS NOT NULL
        THEN
            SELECT MAX (b.Nb_Id)
              INTO l_Apm_Nb
              FROM Uss_Ndi.v_Ndi_Bank b
             WHERE     b.Nb_Mfo =
                       REGEXP_SUBSTR (p_Apm_Account, '[0-9]{6}', 5)
                   AND b.Nb_Nb IS NULL;
        END IF;

        Api$appeal.Save_Payment (p_Apm_Id             => p_Apm_Id,
                                 p_Apm_Ap             => p_Apm_Ap,
                                 p_Apm_Aps            => p_Apm_Aps,
                                 p_Apm_App            => p_Apm_App,
                                 p_Apm_Tp             => p_Apm_Tp,
                                 p_Apm_Index          => p_Apm_Index,
                                 p_Apm_Kaot           => p_Apm_Kaot,
                                 p_Apm_Nb             => l_Apm_Nb,
                                 p_Apm_Account        => p_Apm_Account,
                                 p_Apm_Need_Account   => p_Apm_Need_Account,
                                 p_Apm_Street         => p_Apm_Street,
                                 p_Apm_Ns             => p_Apm_Ns,
                                 p_Apm_Building       => p_Apm_Building,
                                 p_Apm_Block          => p_Apm_Block,
                                 p_Apm_Apartment      => p_Apm_Apartment,
                                 p_Apm_Dppa           => p_Apm_Dppa,
                                 p_New_Id             => p_New_Id);
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END;

    PROCEDURE AddAllAttributeToDoc (p_ap_id IN NUMBER)
    IS
        l_apda_id   NUMBER (14);
    BEGIN
        FOR cur
            IN (SELECT *
                  FROM ap_document apd, appeal ap
                 WHERE     ap.ap_id = p_ap_id
                       AND ap.ap_id = apd.apd_ap
                       AND ap.ap_tp = 'V'
                       AND apd.history_status = 'A')
        LOOP
            FOR cur_1
                IN (SELECT apda.apda_id, nda.nda_id
                      FROM ap_document_attr             apda,
                           uss_ndi.v_ndi_document_attr  nda
                     WHERE     apda.apda_nda(+) = nda.nda_id
                           AND nda.nda_ndt = cur.apd_ndt
                           AND apda.apda_apd(+) = cur.apd_id
                           AND apda.apda_id IS NULL
                           AND nda.history_status = 'A')
            LOOP
                Save_Attributes_Doc (p_Apda_Id           => NULL,
                                     p_Apda_Ap           => cur.apd_ap,
                                     p_Apda_Apd          => cur.apd_id,
                                     p_Apda_Nda          => cur_1.nda_id,
                                     p_New_Id            => l_apda_id,
                                     p_Apda_Val_Int      => NULL,
                                     p_Apda_Val_Dt       => NULL,
                                     p_Apda_Val_String   => NULL,
                                     p_Apda_Val_Id       => NULL,
                                     p_Apda_Val_Sum      => NULL);
            END LOOP;
        END LOOP;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END;


    PROCEDURE ClearApSerice (p_ap_id IN NUMBER)
    IS
    BEGIN
        FOR cur IN (SELECT o.Aps_Id
                      FROM Ap_Service o
                     WHERE o.Aps_Ap = p_Ap_Id AND o.History_Status = 'A')
        LOOP
            Api$appeal.Delete_Service (cur.Aps_Id);
        END LOOP;

        NULL;
    END;

    PROCEDURE ClearPersons (p_ap_id IN NUMBER)
    IS
    BEGIN
        FOR cur IN (SELECT o.app_id
                      FROM Ap_Person o
                     WHERE o.app_ap = p_Ap_Id AND o.History_Status = 'A')
        LOOP
            Api$appeal.Delete_Person (cur.app_id);
        END LOOP;
    END;

    PROCEDURE ClearDocuments (p_ap_id IN NUMBER)
    IS
    BEGIN
        FOR cur IN (SELECT o.apd_id
                      FROM Ap_Document o
                     WHERE o.apd_ap = p_Ap_Id AND o.History_Status = 'A')
        LOOP
            Api$appeal.Delete_Document (cur.apd_id);
        END LOOP;
    END;

    PROCEDURE ClearPayment (p_ap_id IN NUMBER)
    IS
    BEGIN
        FOR cur IN (SELECT o.apm_id
                      FROM Ap_Payment o
                     WHERE o.apm_ap = p_Ap_Id AND o.History_Status = 'A')
        LOOP
            Api$appeal.Delete_Payment (cur.apm_id);
        END LOOP;
    END;

    PROCEDURE ClearAttributes (p_ap_id IN NUMBER)
    IS
    BEGIN
        FOR cur IN (SELECT o.apda_id
                      FROM Ap_Document_Attr o
                     WHERE o.apda_ap = p_Ap_Id AND o.History_Status = 'A')
        LOOP
            Api$appeal.Delete_Document_Attr (cur.apda_id);
        END LOOP;
    END;

    --Для редагування звернення згідно #77769 все преводимо у історію і завантажуємо знову
    PROCEDURE SetAllApealDocumentToHistory (p_ap_id IN NUMBER)
    IS
    BEGIN
        ClearAttributes (p_ap_id);
        ClearDocuments (p_ap_id);
        ClearPayment (p_ap_id);
        ClearPersons (p_ap_id);
    --ClearApSerice(p_ap_id); 20220901 Убираю так как пакетный обмен
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END;

    --отримання даних з усього звернення
    --на даному етапі редагування немає, але про вся квипадок
    PROCEDURE Get_Ap_Doc_Info (p_Ap_Id                  NUMBER,
                               p_Ap_Doc             OUT NUMBER,
                               p_Doc_Edit_Allowed   OUT VARCHAR2,
                               p_Docs_Cur           OUT SYS_REFCURSOR,
                               p_Files_Cur          OUT SYS_REFCURSOR)
    IS
    BEGIN
        Dnet$appeal_Ext.Get_Ap_Info (
            p_Ap_Id              => p_Ap_Id,
            p_Ap_Doc             => p_Ap_Doc,
            p_Doc_Edit_Allowed   => p_Doc_Edit_Allowed,
            p_Docs_Cur           => p_Docs_Cur,
            p_Files_Cur          => p_Files_Cur);
    END;

    PROCEDURE Reg_Appeal_Status_Send (p_ap_id   IN NUMBER,
                                      p_ap_st   IN VARCHAR2 DEFAULT NULL)
    IS
        l_st                appeal.ap_st%TYPE;
        l_ap_src            appeal.ap_src%TYPE;
        l_ap_ext_ident2     uss_visit.appeal.ap_ext_ident2%TYPE;
        l_ap_vf             appeal.ap_vf%TYPE;
        l_ap_tp             appeal.ap_tp%TYPE;
        l_Rn_Id             NUMBER (14);
        l_Ur_Id             NUMBER;
        --l_Parent_Ur NUMBER;
        l_sg_st             VARCHAR2 (10);
        c_Ur_Urt   CONSTANT NUMBER := 42;
        c_ap_vf    CONSTANT NUMBER := 310;
        c_ap_st    CONSTANT NUMBER := 311;
        c_Rn_Nrt   CONSTANT NUMBER := 42;
    BEGIN
        SELECT NVL (p_ap_st, ap.ap_st)     st,
               ap.ap_src,
               ap.ap_vf,
               ap.ap_tp,
               ap.ap_ext_ident2
          INTO l_st,
               l_ap_src,
               l_ap_vf,
               l_ap_tp,
               l_ap_ext_ident2
          FROM uss_visit.appeal ap
         WHERE ap.ap_id = p_ap_id;

        Decode_Dic_Value ('CS_AP_SND',
                          'VST',
                          l_ap_src,
                          l_st,
                          l_sg_st);

        IF NOT (    l_ap_src IN ('COM', 'DIIA')
                AND l_ap_tp = 'V'
                AND l_sg_st IS NOT NULL
                AND l_ap_ext_ident2 IS NOT NULL)
        THEN
            RETURN;
        END IF;

        ikis_rbm.Api$uxp_Request.Register_Out_Request (
            p_Ur_Plan_Dt     => SYSDATE,
            p_Ur_Urt         => c_Ur_Urt,
            p_Ur_Create_Wu   => NULL,
            p_Ur_Ext_Id      => p_ap_id,
            p_Ur_Body        => NULL,
            p_New_Id         => l_Ur_Id,
            p_Rn_Nrt         => c_Rn_Nrt,
            p_Rn_Src         => l_ap_src,
            p_Rn_Hs_Ins      => NULL,
            p_New_Rn_Id      => l_Rn_Id);

        Ikis_Rbm.Api$request.Save_Rn_Common_Info (p_Rnc_Rn       => l_Rn_Id,
                                                  p_Rnc_Pt       => c_ap_vf,
                                                  p_Rnc_Val_Id   => l_ap_vf);
        Ikis_Rbm.Api$request.Save_Rn_Common_Info (p_Rnc_Rn           => l_Rn_Id,
                                                  p_Rnc_Pt           => c_ap_st,
                                                  p_Rnc_Val_String   => l_st);
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;
            Raise_Application_Error (
                -20000,
                   'DNET$COMMUNITY.Reg_Appeal_Status_Send_Req: '
                || CHR (13)
                || SQLERRM
                || CHR (13)
                || DBMS_UTILITY.Format_Error_Backtrace);
    END;

    FUNCTION Get_Appeal_Status_Send_Req (p_Ur_Id IN NUMBER)
        RETURN CLOB
    IS
        l_Ur_Rn            NUMBER;
        c_ap_vf   CONSTANT NUMBER := 310;
        c_ap_st   CONSTANT NUMBER := 311;
        l_ap_id            appeal.ap_id%TYPE;
        l_ap_st            appeal.ap_st%TYPE;
        l_clob             CLOB;
        l_id_sg            NUMBER (14);
        l_ap_vf            appeal.ap_vf%TYPE;
        l_message          VARCHAR2 (4000);
        l_ap_src           appeal.ap_src%TYPE;
        l_sg_st            VARCHAR2 (10);
        l_status_dt        DATE;
        l_aps_id           NUMBER (14);
    BEGIN
        l_Ur_Rn := Ikis_Rbm.Api$uxp_Request.Get_Ur_Rn (p_Ur_Id);

        SELECT r.ur_ext_id, r.ur_create_dt
          INTO l_ap_id, l_status_dt
          FROM ikis_rbm.v_uxp_request r
         WHERE r.ur_id = p_Ur_Id;

        SELECT ap.ap_src, ap.ap_ext_ident2
          INTO l_ap_src, l_id_sg
          FROM appeal ap
         WHERE ap.ap_id = l_ap_id;

        l_ap_st :=
            Ikis_Rbm.Api$request.Get_Rn_Common_Info_String (l_Ur_Rn, c_ap_st);
        l_ap_vf :=
            Ikis_Rbm.Api$request.Get_Rn_Common_Info_Id (l_Ur_Rn, c_ap_vf);
        Decode_Dic_Value ('CS_AP_SND',
                          'VST',
                          l_ap_src,
                          l_ap_st,
                          l_sg_st);
        l_aps_id := GetApsByAp (l_ap_id, 664);

        IF l_ap_vf IS NOT NULL
        THEN
            /*
               SELECT Listagg(CASE
                                WHEN p.App_Id IS NOT NULL THEN
                                  p.App_Ln || ' ' || p.App_Fn || ' ' || p.App_Mn || ': '
                              END || Uss_Ndi.Rdm$msg_Template.Getmessagetext(l.Vfl_Message),
                              ';' || Chr(13) || Chr(10)) Within GROUP(ORDER BY l.Vfl_Id)
            */
            --#110450
            SELECT RTRIM (
                       XMLAGG (XMLELEMENT (
                                   e,
                                      CASE
                                          WHEN p.app_id IS NOT NULL
                                          THEN
                                                 p.app_ln
                                              || ' '
                                              || p.app_fn
                                              || ' '
                                              || p.app_mn
                                              || ': '
                                      END
                                   || Uss_Ndi.Rdm$msg_Template.Getmessagetext (
                                          l.vfl_message),
                                   ';' || CHR (13) || CHR (10)).EXTRACT (
                                   '//text()')
                               ORDER BY l.vfl_id).getclobval (),
                       ';' || CHR (13) || CHR (10))
              INTO l_Message
              FROM Vf_Log  l
                   JOIN Verification v ON l.Vfl_Vf = v.Vf_Id
                   JOIN Verification Vv ON v.Vf_Vf_Main = Vv.Vf_Id
                   LEFT JOIN Ap_Person p
                       ON Vv.Vf_Obj_Tp = 'P' AND Vv.Vf_Obj_Id = p.App_Id
             WHERE     l.Vfl_Vf IN
                           (    SELECT t.Vf_Id
                                  FROM Verification t
                                 WHERE t.Vf_Nvt <>
                                       Api$verification.c_Nvt_Rzo_Search
                            START WITH t.Vf_Id = l_Ap_Vf
                            CONNECT BY PRIOR t.Vf_Id = t.Vf_Vf_Main)
                   AND l.Vfl_Tp IN ('W', 'E');
        END IF;

        SELECT XMLELEMENT (
                   "saveResultRequest1",
                   XMLELEMENT (
                       "saveResultRequest",
                       XMLELEMENT (
                           "result",
                           XMLAttributes (
                               'http://www.ioc.gov.ua/community' AS "xmlns"),
                           XMLELEMENT ("id", l_id_sg),
                           XMLELEMENT ("apId", l_aps_id),
                           XMLELEMENT ("status", l_sg_st),
                           XMLELEMENT (
                               "savedTime",
                               TO_CHAR (l_status_dt,
                                        'yyyy-mm-dd"T"HH24:mi:ss')),
                           XMLELEMENT ("code", 0),
                           XMLELEMENT ("message", l_message)))).getClobVal ()
          INTO l_clob
          FROM DUAL;

        RETURN l_clob;
    END;

    PROCEDURE Handler_Appeal_Status_Send_Result (
        p_Ur_Id      IN     NUMBER,
        p_Response   IN     CLOB,
        p_Error      IN OUT VARCHAR2)
    IS
        l_res     VARCHAR2 (4000);
        l_doc     DBMS_XMLDOM.DOMDocument;
        l_nlist   DBMS_XMLDOM.DOMNodeList;
        l_node    DBMS_XMLDOM.DOMNode;
        l_len     NUMBER;
    BEGIN
        IF p_Error IS NOT NULL
        THEN
            Ikis_Rbm.Api$uxp_Request.Delay_Request_Exception (
                p_Ur_Id           => p_Ur_Id,
                p_Delay_Seconds   => 300,
                p_Delay_Reason    => p_Error);
        END IF;

        BEGIN
            l_doc := DBMS_XMLDOM.newDOMDocument (xmltype (p_Response));
            l_nlist := DBMS_XMLDOM.getElementsByTagName (l_doc, 'code');
            l_len := DBMS_XMLDOM.getLength (l_nlist);

            IF l_len > 0
            THEN
                l_node := DBMS_XMLDOM.item (l_nlist, 0);
                l_res :=
                    DBMS_XMLDOM.getnodevalue (xmldom.getfirstchild (l_node));
            END IF;

            DBMS_XMLDOM.freeDocument (l_doc);

            IF l_res IN ('0',
                         '3',
                         '4',
                         '5',
                         '404',
                         '1')
            THEN
                NULL;
            ELSIF l_res IN ('6', '504')
            THEN
                Ikis_Rbm.Api$uxp_Request.Delay_Request_Exception (
                    p_Ur_Id           => p_Ur_Id,
                    p_Delay_Seconds   => 300,
                    p_Delay_Reason    => p_Error);
            ELSE
                NULL;
            END IF;
        /*exception
          when others then
            null;*/
        END;
    END;

    --20230412
    --Визначення Ід послуги по коду
    FUNCTION GetNstByComCode (p_code IN VARCHAR2)
        RETURN NUMBER
    IS
        l_nst_id   NUMBER (14);
    BEGIN
        SELECT nst.nst_id
          INTO l_nst_id
          FROM uss_ndi.v_ndi_payment_type  npt,
               uss_ndi.v_ndi_npt_config    nptc,
               uss_ndi.v_ndi_service_type  nst
         WHERE     npt.npt_id = nptc.nptc_npt
               AND nptc.nptc_nst = nst.nst_id
               AND npt.history_status = 'A'
               AND nst.history_status = 'A'
               AND npt.npt_code = UPPER (TRIM (p_code));

        RETURN l_nst_id;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN NULL;
    END;

    FUNCTION GetNstByComId (p_Id IN NUMBER)
        RETURN NUMBER
    IS
        l_nst_id   NUMBER (14);
    BEGIN
        SELECT d.nddc_code_dest
          INTO l_nst_id
          FROM uss_ndi.v_ndi_decoding_config d
         WHERE     d.nddc_tp = 'NST_ID'
               AND d.nddc_src = 'COM'
               AND d.nddc_dest = 'VST'
               AND d.nddc_code_src = p_Id;

        RETURN l_nst_id;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN NULL;
    END;

    FUNCTION IsAllowProcessed (p_ap_id           IN     NUMBER,
                               p_ap_ext_ident2          NUMBER,
                               p_aps_id          IN     NUMBER,
                               p_comment            OUT VARCHAR2,
                               p_nst_id          IN     NUMBER)
        RETURN NUMBER
    IS
        l_cnt                 NUMBER (14);
        l_ap_id               NUMBER (14) := p_ap_id;
        l_ap_is_ext_process   appeal.ap_is_ext_process%TYPE;
    BEGIN
        RequestLock (p_ap_ext_ident2);

        IF p_aps_id IS NOT NULL
        THEN                                                        --20220901
            --звернення від дії
            SELECT MAX (ap.ap_is_ext_process)
              INTO l_ap_is_ext_process
              FROM appeal ap
             WHERE     ap.ap_tp IN ('V', 'VPO')
                   AND ap.ap_id = l_ap_id
                   AND ap.ap_src = 'DIIA';

            --дозволяється збереження заяви с джерелом Дія, якщо встановлено ознаку "Завнішня обробка"
            --(після першого збереження від СГ ознака переходить в F)
            IF l_ap_is_ext_process = 'T'
            THEN
                RETURN 1;
            END IF;

            --забороняємо повторне збереження заяви від СГ з джерелом Дія
            IF l_ap_is_ext_process = 'F'
            THEN
                p_comment :=
                    'Збереження звернення від Дії в поточному статусі заборонено';
                RETURN 0;
            END IF;

            --тут наш ід + ід СГ
            SELECT COUNT (1)
              INTO l_cnt
              FROM appeal ap
             WHERE     ap.ap_tp = 'V'
                   AND ap.ap_ext_ident2 = p_ap_ext_ident2
                   AND ap.ap_id = l_ap_id
                   AND ap.ap_src = 'COM'
                   --and ap.ap_st in ('VE', 'W') Неуспішна верифікація Очікування документів
                   AND ap.ap_st IN ('B')         --#88585 Повернуто з ОСЗН/ССД
                   AND EXISTS
                           (SELECT 1
                              FROM ap_service aps
                             WHERE     aps.aps_ap = ap.ap_id
                                   AND aps.aps_nst = p_nst_id
                                   AND aps.history_status = 'A')
                   AND NOT EXISTS
                           (SELECT 1
                              FROM ap_service aps1
                             WHERE     aps1.aps_ap = ap.ap_id
                                   AND aps1.aps_nst != p_nst_id
                                   AND aps1.history_status = 'A');

            IF l_cnt = 1
            THEN
                RETURN 1;
            END IF;

            IF l_cnt = 0
            THEN
                --Важно помнить apId для СГ это apsId
                p_comment :=
                       'Не знайдено звернення з apId='
                    || p_aps_id
                    || ' і id='
                    || p_ap_ext_ident2
                    || ', або звернення у невідповідному статусі';
                RETURN 0;
            END IF;
        END IF;

        IF l_ap_id IS NULL AND p_aps_id IS NULL
        THEN
            SELECT COUNT (1)
              INTO l_cnt
              FROM appeal ap
             WHERE     ap.ap_tp = 'V'
                   AND ap.ap_ext_ident2 = p_ap_ext_ident2
                   AND ap.ap_src IN ('DIIA', 'COM');

            IF l_cnt = 0
            THEN
                RETURN 1;
            ELSE
                RETURN 0;
            END IF;
        END IF;

        RETURN NULL;
    EXCEPTION
        WHEN OTHERS
        THEN
            raise_application_error (
                -20000,
                   SQLERRM
                || DBMS_UTILITY.format_error_stack
                || DBMS_UTILITY.format_error_backtrace);
    END;
END DNET$COMMUNITY;
/