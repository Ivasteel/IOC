/* Formatted on 8/12/2025 6:06:31 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_FINZVIT.ikis_finzvit_context
IS
    -- Author  : MAXYM
    -- Created : 09.10.2017 16:03:02
    -- Purpose : DB Context

    gContext   CONSTANT VARCHAR2 (20) := 'IKISFINZVIT';

    --Attr
    gUID       CONSTANT VARCHAR2 (10) := 'IKISUID';
    gUserTP    CONSTANT VARCHAR2 (10) := 'IUTP';
    gUTPcd     CONSTANT VARCHAR2 (10) := 'IUTPCD';
    gOPFU      CONSTANT VARCHAR2 (10) := 'OPFU';
    gPOPFU     CONSTANT VARCHAR2 (10) := 'POPFU';
    gUser      CONSTANT VARCHAR2 (10) := 'USER';

    TYPE tRoles IS RECORD
    (
        rl_nm    VARCHAR2 (20),
        rl_cd    VARCHAR2 (10)
    );

    TYPE vRole IS TABLE OF tRoles
        INDEX BY BINARY_INTEGER;

    gRole               vRole;

    PROCEDURE SetContext (p_user VARCHAR2);
END ikis_finzvit_context;
/


/* Formatted on 8/12/2025 6:06:33 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_FINZVIT.ikis_finzvit_context
IS
    PROCEDURE SetContext (p_user VARCHAR2)
    IS
        l_uid     NUMBER;
        l_tp      NUMBER;
        l_pfu     NUMBER;
        l_ppfu    NUMBER;
        l_trc     VARCHAR2 (10);
        l_tp_cd   VARCHAR2 (10);
        l_cnt     NUMBER := 0;
        l_user    VARCHAR2 (50) := p_user;
    --  l_cur_user varchar2(50);

    BEGIN
        GetUserAttr (p_username   => UPPER (l_user),
                     p_uid        => l_uid,
                     p_wut        => l_tp,
                     p_org        => l_pfu,
                     p_trc        => l_trc);

        --Подчитываю тип
        l_tp_cd :=
            CASE
                WHEN l_tp = 4 THEN 'UIC'
                WHEN l_tp = 5 THEN 'URE'
                WHEN l_tp = 6 THEN 'UMU'
            END;

        -- parent pfu
        BEGIN
            SELECT o.org_org
              INTO l_ppfu
              FROM v_opfu o
             WHERE o.org_id = l_pfu;
        EXCEPTION
            WHEN OTHERS
            THEN
                BEGIN
                    l_ppfu := -1;
                END;
        END;

        --    raise_application_error(-20000, l_uid);
        -- set context
        DBMS_SESSION.set_context (namespace   => gContext,
                                  attribute   => gUID,
                                  VALUE       => l_uid);
        DBMS_SESSION.set_context (namespace   => gContext,
                                  attribute   => gUser,
                                  VALUE       => l_user);
        DBMS_SESSION.set_context (namespace   => gContext,
                                  attribute   => gUserTP,
                                  VALUE       => l_tp);
        DBMS_SESSION.set_context (namespace   => gContext,
                                  attribute   => gOPFU,
                                  VALUE       => l_pfu);
        DBMS_SESSION.set_context (namespace   => gContext,
                                  attribute   => gPOPFU,
                                  VALUE       => l_ppfu);
        DBMS_SESSION.set_context (namespace   => gContext,
                                  attribute   => gUTPcd,
                                  VALUE       => l_tp_cd);

        gRole (1).rl_nm := 'W_FINZVIT_OPR';
        gRole (1).rl_cd := 'OPR';                         -- ФІНЗВІТ: Оператор

        FOR ii IN 1 .. 1
        LOOP
            IF is_role_assigned (p_username   => l_user,
                                 p_role       => gRole (ii).rl_nm,
                                 p_user_tp    => l_tp_cd)
            THEN
                DBMS_SESSION.set_context (namespace   => gContext,
                                          attribute   => gRole (ii).rl_cd,
                                          VALUE       => 'T');
                l_cnt := l_cnt + 1;
            ELSE
                DBMS_SESSION.set_context (namespace   => gContext,
                                          attribute   => gRole (ii).rl_cd,
                                          VALUE       => 'F');
            END IF;
        END LOOP;
    END;
END ikis_finzvit_context;
/