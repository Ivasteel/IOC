/* Formatted on 8/12/2025 6:11:41 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYSWEB.IKIS_WEB_TRACE
IS
    -- Author  : YURA_A
    -- Created : 17.04.2006 16:24:45
    -- Purpose : Trace facility for IKIS-WEB application

    --P_SECTION
    gRender   CONSTANT NUMBER := 0;
    gSubmit   CONSTANT NUMBER := 1;

    --P_PLACE
    gBegin    CONSTANT NUMBER := 0;
    gEnd      CONSTANT NUMBER := 1;

    ----------------------------------------
    -- YURA_A 17.04.2006 17:38:48
    ----------------------------------------
    -- Назначение : Запись строки в трейс-файл для идентификации пользовательских операций
    -- Параметры  :
    PROCEDURE write_message (P_APP_ID        NUMBER,
                             P_APP_PAGE_ID   NUMBER,
                             P_APP_SESSION   VARCHAR2,
                             P_APP_USER      VARCHAR2,
                             P_SECTION       VARCHAR2,
                             P_PLACE         VARCHAR2);


    PROCEDURE WriteTraceMsg (p_msg VARCHAR2);

    ----------------------------------------
    -- YURA_A 17.04.2006 17:38:50
    ----------------------------------------
    -- Назначение : Установка уровня трассировки set events 10046
    -- Параметры  : p_level - 0,4,8,12
    PROCEDURE StartTrace (p_level VARCHAR2);

    PROCEDURE StartTraceJob (p_level VARCHAR2, p_jobname VARCHAR2);
END IKIS_WEB_TRACE;
/


CREATE OR REPLACE PUBLIC SYNONYM IKIS_WEB_TRACE FOR IKIS_SYSWEB.IKIS_WEB_TRACE
/


GRANT EXECUTE ON IKIS_SYSWEB.IKIS_WEB_TRACE TO II01RC_SYSWEB_COMM
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_WEB_TRACE TO IKIS_RBM
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_WEB_TRACE TO IKIS_WEBPROXY
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_WEB_TRACE TO USS_ESR
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_WEB_TRACE TO USS_EXCH
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_WEB_TRACE TO USS_NDI
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_WEB_TRACE TO USS_PERSON
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_WEB_TRACE TO USS_RNSP
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_WEB_TRACE TO USS_RPT
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_WEB_TRACE TO USS_VISIT
/


/* Formatted on 8/12/2025 6:11:45 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_SYSWEB.IKIS_WEB_TRACE
IS
    PROCEDURE WriteTraceMsg (p_msg VARCHAR2)
    IS
    --  l_trc number;
    BEGIN
        --  sys.dbms_system.read_ev(10046,l_trc);
        --  if not(l_trc=0) then
        sys.DBMS_SYSTEM.ksdddt;
        sys.DBMS_SYSTEM.ksdwrt (dest => 1, tst => p_msg);
    --  end if;
    END;

    PROCEDURE write_message (P_APP_ID        NUMBER,
                             P_APP_PAGE_ID   NUMBER,
                             P_APP_SESSION   VARCHAR2,
                             P_APP_USER      VARCHAR2,
                             P_SECTION       VARCHAR2,
                             P_PLACE         VARCHAR2)
    IS
        l_msg   VARCHAR2 (100);
        l_trc   NUMBER;
    BEGIN
        sys.DBMS_SYSTEM.read_ev (10046, l_trc);

        IF NOT (l_trc = 0)
        THEN
            CASE
                WHEN P_SECTION = gRender AND P_PLACE = gBegin
                THEN
                    l_msg := '--RND:BGN:';
                WHEN P_SECTION = gRender AND P_PLACE = gEnd
                THEN
                    l_msg := '--RND:END:';
                WHEN P_SECTION = gSubmit AND P_PLACE = gBegin
                THEN
                    l_msg := '--SBM:BGN:';
                WHEN P_SECTION = gSubmit AND P_PLACE = gEnd
                THEN
                    l_msg := '--SBM:END:';
                ELSE
                    l_msg := '--UNK:UNK:';
            END CASE;

            DBMS_APPLICATION_INFO.set_action (
                action_name   =>
                       l_msg
                    || TO_NUMBER (P_APP_ID)
                    || ':'
                    || TO_NUMBER (P_APP_PAGE_ID));
            WriteTraceMsg (
                   l_msg
                || TO_NUMBER (P_APP_ID)
                || ':'
                || TO_NUMBER (P_APP_PAGE_ID)
                || ':'
                || P_APP_SESSION
                || ':'
                || P_APP_USER
                || '--');
        END IF;
    END;

    PROCEDURE StartTrace (p_level VARCHAR2)
    IS
        l_trc     NUMBER;
        l_app     NUMBER;
        l_page    NUMBER;
        l_level   NUMBER;
    BEGIN
        --level;app;page
        IF INSTR (p_level, ';') > 0
        THEN
            l_level :=
                TO_NUMBER (SUBSTR (p_level, 1, INSTR (p_level, ';') - 1));
            l_app :=
                TO_NUMBER (SUBSTR (p_level,
                                   INSTR (p_level, ';') + 1,
                                     INSTR (p_level,
                                            ';',
                                            1,
                                            2)
                                   - INSTR (p_level,
                                            ';',
                                            1,
                                            1)
                                   - 1));
            l_page :=
                TO_NUMBER (SUBSTR (p_level,
                                     INSTR (p_level,
                                            ';',
                                            1,
                                            2)
                                   + 1));
        ELSE
            l_level := '0';                              --to_number(p_level);
            l_page := NULL;
            l_app := NULL;
        END IF;

        sys.DBMS_SYSTEM.read_ev (10046, l_trc);

        --ikis_htmldb_common.pipe_debug(0,l_trc||';'||l_level||';'||l_page||';'||NV('APP_PAGE_ID'));

        IF (    (l_trc = 0)
            AND (l_level IN ('4', '8', '12'))
            AND NVL (l_page, NV ('APP_PAGE_ID')) = NV ('APP_PAGE_ID')
            AND NVL (l_app, NV ('APP_ID')) = NV ('APP_ID'))
        THEN
            EXECUTE IMMEDIATE   'alter session set tracefile_identifier='''
                             || SUBSTR (v ('USER'), 1, 6)
                             || '_'
                             || NV ('APP_ID')
                             || '_'
                             || NV ('APP_PAGE_ID')
                             || '''';

            EXECUTE IMMEDIATE   'alter session set events ''10046 trace name context forever, level '
                             || l_level
                             || '''';
        END IF;

        IF    (NOT (l_trc = 0) AND (l_level = '0'))
           OR (    NOT (l_trc = 0)
               AND (   NOT (NVL (l_page, NV ('APP_PAGE_ID')) =
                            NV ('APP_PAGE_ID'))
                    OR NOT (NVL (l_app, NV ('APP_ID')) = NV ('APP_ID'))))
        THEN
            EXECUTE IMMEDIATE 'alter session set events ''10046 trace name context off''';
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            WriteTraceMsg ('Error in IKIS_WEB_TRACE.StartTrace: ' || p_level);
    END;

    PROCEDURE StartTraceJob (p_level VARCHAR2, p_jobname VARCHAR2)
    IS
        l_trc     NUMBER;
        l_app     NUMBER;
        l_page    NUMBER;
        l_level   NUMBER;
    BEGIN
        --level~JOB
        IF INSTR (p_level, '~') > 0
        THEN
            l_level :=
                TO_NUMBER (SUBSTR (p_level, 1, INSTR (p_level, '~') - 1));
        --    l_app:=to_number(substr(p_level,instr(p_level,';')+1,instr(p_level,';',1,2)-instr(p_level,';',1,1)-1));
        --    l_page:=to_number(substr(p_level,instr(p_level,';',1,2)+1));
        ELSE
            l_level := '0';                              --to_number(p_level);
        --    l_page:=NULL;l_app:=null;
        END IF;

        sys.DBMS_SYSTEM.read_ev (10046, l_trc);

        --ikis_htmldb_common.pipe_debug(0,l_trc||';'||l_level||';'||l_page||';'||NV('APP_PAGE_ID'));

        IF ((l_trc = 0) AND (l_level IN ('4', '8', '12')))
        THEN
            EXECUTE IMMEDIATE   'alter session set tracefile_identifier='''
                             || p_jobname
                             || '''';

            EXECUTE IMMEDIATE   'alter session set events ''10046 trace name context forever, level '
                             || l_level
                             || '''';
        END IF;

        IF (NOT (l_trc = 0) AND (l_level = '0'))
        THEN
            EXECUTE IMMEDIATE 'alter session set events ''10046 trace name context off''';
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            WriteTraceMsg (
                'Error in IKIS_WEB_TRACE.StartTraceJob: ' || p_level);
    END;
END IKIS_WEB_TRACE;
/