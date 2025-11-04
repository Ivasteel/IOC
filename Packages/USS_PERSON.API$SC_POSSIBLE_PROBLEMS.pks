/* Formatted on 8/12/2025 5:56:54 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_PERSON.API$SC_POSSIBLE_PROBLEMS
IS
    -- Author  : VANO
    -- Created : 01.10.2024 16:13:52
    -- Purpose : Пакет маніпуляцій з журналом можливих проблем з картками СРКО


    --Вставка запису можливої проблеми
    PROCEDURE insert_sc_possible_problems (
        p_spp_id         OUT sc_possible_problems.spp_id%TYPE,
        p_spp_sc             sc_possible_problems.spp_sc%TYPE,
        p_spp_tp             sc_possible_problems.spp_tp%TYPE,
        p_spp_src_info       sc_possible_problems.spp_src_info%TYPE,
        p_spp_init_org       sc_possible_problems.spp_init_org%TYPE,
        p_spp_hs_ins         sc_possible_problems.spp_hs_ins%TYPE DEFAULT NULL);

    --Передача записів на обробку в ОСЗН
    PROCEDURE forward_sc_possible_problems (
        p_spp_id     sc_possible_problems.spp_id%TYPE,
        p_dest_org   sc_possible_problems.com_org%TYPE);

    --Можлива проблема з СРКО - оброблена
    PROCEDURE make_processed (
        p_spp_id              sc_possible_problems.spp_id%TYPE,
        p_spp_decision_desc   sc_possible_problems.spp_decision_desc%TYPE);

    --Можлива проблема з СРКО - не підтвердилось
    PROCEDURE make_not_confirmed (
        p_spp_id              sc_possible_problems.spp_id%TYPE,
        p_spp_decision_desc   sc_possible_problems.spp_decision_desc%TYPE);
END API$SC_POSSIBLE_PROBLEMS;
/


GRANT EXECUTE ON USS_PERSON.API$SC_POSSIBLE_PROBLEMS TO USS_ESR
/

GRANT EXECUTE ON USS_PERSON.API$SC_POSSIBLE_PROBLEMS TO USS_RNSP
/

GRANT EXECUTE ON USS_PERSON.API$SC_POSSIBLE_PROBLEMS TO USS_RPT
/

GRANT EXECUTE ON USS_PERSON.API$SC_POSSIBLE_PROBLEMS TO USS_VISIT
/


/* Formatted on 8/12/2025 5:56:57 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_PERSON.API$SC_POSSIBLE_PROBLEMS
IS
    --Вставка запису можливої проблеми
    PROCEDURE insert_sc_possible_problems (
        p_spp_id         OUT sc_possible_problems.spp_id%TYPE,
        p_spp_sc             sc_possible_problems.spp_sc%TYPE,
        p_spp_tp             sc_possible_problems.spp_tp%TYPE,
        p_spp_src_info       sc_possible_problems.spp_src_info%TYPE,
        p_spp_init_org       sc_possible_problems.spp_init_org%TYPE,
        p_spp_hs_ins         sc_possible_problems.spp_hs_ins%TYPE DEFAULT NULL)
    IS
        l_spp_hs_ins   sc_possible_problems.spp_hs_ins%TYPE;
    BEGIN
        l_spp_hs_ins :=
            CASE
                WHEN p_spp_hs_ins IS NOT NULL THEN p_spp_hs_ins
                ELSE TOOLS.GetHistSession
            END;

        INSERT INTO sc_possible_problems (spp_id,
                                          spp_sc,
                                          spp_tp,
                                          spp_src_info,
                                          spp_st,
                                          spp_hs_ins,
                                          spp_init_org,
                                          com_org)
             VALUES (0,
                     p_spp_sc,
                     p_spp_tp,
                     p_spp_src_info,
                     'E',
                     l_spp_hs_ins,
                     p_spp_init_org,
                     p_spp_init_org)
          RETURNING spp_id
               INTO p_spp_id;
    END insert_sc_possible_problems;

    --Передача записів на обробку в ОСЗН
    PROCEDURE forward_sc_possible_problems (
        p_spp_id     sc_possible_problems.spp_id%TYPE,
        p_dest_org   sc_possible_problems.com_org%TYPE)
    IS
        l_org   sc_possible_problems.com_org%TYPE;
        l_spp   sc_possible_problems%ROWTYPE;
    BEGIN
        BEGIN
            SELECT *
              INTO l_spp
              FROM sc_possible_problems
             WHERE spp_id = p_spp_id
            FOR UPDATE;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                raise_application_error (-20000, 'Не існує такого рядка!');
        END;

        BEGIN
            SELECT org_id
              INTO l_org
              FROM opfu
             WHERE org_id = p_dest_org AND org_to = 32 AND org_st = 'A';
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                raise_application_error (-20000, 'Вкажіть діючий ОСЗН!');
        END;

        IF l_spp.com_org = p_dest_org
        THEN
            raise_application_error (
                -20000,
                'Запис вже на обробці у вказаному ОСЗН!');
        END IF;

        IF TOOLS.GetCurrOrgTo = 40
        THEN
            UPDATE sc_possible_problems
               SET com_org = l_org, spp_hs_forward = TOOLS.GetHistSession
             WHERE spp_id = l_spp.spp_id;
        ELSE
            raise_application_error (
                -20000,
                'Функція передачі доступна тільки користувачам ІОЦ');
        END IF;
    END;

    --Внутрішня процедура оновлення статусу
    PROCEDURE internal_set_status (
        p_spp_id              sc_possible_problems.spp_id%TYPE,
        p_spp_st              sc_possible_problems.spp_st%TYPE,
        p_spp_decision_desc   sc_possible_problems.spp_decision_desc%TYPE)
    IS
        l_spp   sc_possible_problems%ROWTYPE;
        l_hs    histsession.hs_id%TYPE;
    BEGIN
        SELECT *
          INTO l_spp
          FROM sc_possible_problems
         WHERE spp_id = p_spp_id
        FOR UPDATE;

        l_hs := TOOLS.GetHistSession;

        UPDATE sc_possible_problems
           SET spp_st = p_spp_st,
               spp_decision_desc = p_spp_decision_desc,
               spp_hs_decision = l_hs
         WHERE spp_id = p_spp_id;

        Api$socialcard.write_sc_log (l_spp.spp_sc,
                                     l_hs,
                                     NULL,
                                     CHR (38) || '312',
                                     NULL,
                                     NULL);
    END;

    --Можлива проблема з СРКО - оброблена
    PROCEDURE make_processed (
        p_spp_id              sc_possible_problems.spp_id%TYPE,
        p_spp_decision_desc   sc_possible_problems.spp_decision_desc%TYPE)
    IS
    BEGIN
        internal_set_status (p_spp_id, 'O', p_spp_decision_desc);
    END;

    --Можлива проблема з СРКО - не підтвердилось
    PROCEDURE make_not_confirmed (
        p_spp_id              sc_possible_problems.spp_id%TYPE,
        p_spp_decision_desc   sc_possible_problems.spp_decision_desc%TYPE)
    IS
    BEGIN
        internal_set_status (p_spp_id, 'F', p_spp_decision_desc);
    END;
BEGIN
    NULL;
END API$SC_POSSIBLE_PROBLEMS;
/