/* Formatted on 8/12/2025 5:57:57 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_RNSP.PRIV$RNSP_STATE
IS
    -- ַבונודעט
    PROCEDURE Save (
        p_RNSPS_ID                    IN     RNSP_STATE.RNSPS_ID%TYPE,
        p_RNSPS_RNSPM                 IN     RNSP_STATE.RNSPS_RNSPM%TYPE,
        p_RNSPS_RNSPA                 IN     RNSP_STATE.RNSPS_RNSPA%TYPE,
        /*p_RNSPS_RNSPA1 in RNSP_STATE.RNSPS_RNSPA1%type,
        p_RNSPS_RNSPA2              in RNSP_STATE.RNSPS_RNSPA2%type,
        p_RNSPS_RNSPA3              in RNSP_STATE.RNSPS_RNSPA3%type,
        p_RNSPS_RNSPA4              in RNSP_STATE.RNSPS_RNSPA4%type,*/
        p_RNSPS_NUMIDENT              IN     RNSP_STATE.RNSPS_NUMIDENT%TYPE,
        p_RNSPS_IS_NUMIDENT_MISSING   IN     RNSP_STATE.RNSPS_IS_NUMIDENT_MISSING%TYPE,
        p_RNSPS_PASS_SERIA            IN     RNSP_STATE.RNSPS_PASS_SERIA%TYPE,
        p_RNSPS_PASS_NUM              IN     RNSP_STATE.RNSPS_PASS_NUM%TYPE,
        p_RNSPS_LAST_NAME             IN     RNSP_STATE.RNSPS_LAST_NAME%TYPE,
        p_RNSPS_FIRST_NAME            IN     RNSP_STATE.RNSPS_FIRST_NAME%TYPE,
        p_RNSPS_MIDDLE_NAME           IN     RNSP_STATE.RNSPS_MIDDLE_NAME%TYPE,
        p_RNSPS_GENDER                IN     RNSP_STATE.RNSPS_GENDER%TYPE,
        p_RNSPS_DATE_BIRTH            IN     RNSP_STATE.RNSPS_DATE_BIRTH%TYPE,
        p_RNSPS_NC                    IN     RNSP_STATE.RNSPS_NC%TYPE,
        p_RNSPS_RNSPO                 IN     RNSP_STATE.RNSPS_RNSPO%TYPE,
        p_RNSPS_HS                    IN     RNSP_STATE.RNSPS_HS%TYPE,
        p_HISTORY_STATUS              IN     RNSP_STATE.HISTORY_STATUS%TYPE,
        p_RNSPS_OWNERSHIP             IN     RNSP_STATE.RNSPS_OWNERSHIP%TYPE,
        p_RNSPS_EDR_STATE             IN     RNSP_STATE.RNSPS_EDR_STATE%TYPE,
        p_new_id                         OUT RNSP_STATE.RNSPS_ID%TYPE);
END PRIV$RNSP_STATE;
/


/* Formatted on 8/12/2025 5:58:02 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_RNSP.PRIV$RNSP_STATE
IS
    -- ַבונודעט
    PROCEDURE Save (
        p_RNSPS_ID                    IN     RNSP_STATE.RNSPS_ID%TYPE,
        p_RNSPS_RNSPM                 IN     RNSP_STATE.RNSPS_RNSPM%TYPE,
        p_RNSPS_RNSPA                 IN     RNSP_STATE.RNSPS_RNSPA%TYPE,
        /* p_RNSPS_RNSPA1 in RNSP_STATE.RNSPS_RNSPA1%type,
         p_RNSPS_RNSPA2              in RNSP_STATE.RNSPS_RNSPA2%type,
         p_RNSPS_RNSPA3              in RNSP_STATE.RNSPS_RNSPA3%type,
         p_RNSPS_RNSPA4              in RNSP_STATE.RNSPS_RNSPA4%type,*/
        p_RNSPS_NUMIDENT              IN     RNSP_STATE.RNSPS_NUMIDENT%TYPE,
        p_RNSPS_IS_NUMIDENT_MISSING   IN     RNSP_STATE.RNSPS_IS_NUMIDENT_MISSING%TYPE,
        p_RNSPS_PASS_SERIA            IN     RNSP_STATE.RNSPS_PASS_SERIA%TYPE,
        p_RNSPS_PASS_NUM              IN     RNSP_STATE.RNSPS_PASS_NUM%TYPE,
        p_RNSPS_LAST_NAME             IN     RNSP_STATE.RNSPS_LAST_NAME%TYPE,
        p_RNSPS_FIRST_NAME            IN     RNSP_STATE.RNSPS_FIRST_NAME%TYPE,
        p_RNSPS_MIDDLE_NAME           IN     RNSP_STATE.RNSPS_MIDDLE_NAME%TYPE,
        p_RNSPS_GENDER                IN     RNSP_STATE.RNSPS_GENDER%TYPE,
        p_RNSPS_DATE_BIRTH            IN     RNSP_STATE.RNSPS_DATE_BIRTH%TYPE,
        p_RNSPS_NC                    IN     RNSP_STATE.RNSPS_NC%TYPE,
        p_RNSPS_RNSPO                 IN     RNSP_STATE.RNSPS_RNSPO%TYPE,
        p_RNSPS_HS                    IN     RNSP_STATE.RNSPS_HS%TYPE,
        p_HISTORY_STATUS              IN     RNSP_STATE.HISTORY_STATUS%TYPE,
        p_RNSPS_OWNERSHIP             IN     RNSP_STATE.RNSPS_OWNERSHIP%TYPE,
        p_RNSPS_EDR_STATE             IN     RNSP_STATE.RNSPS_EDR_STATE%TYPE,
        p_new_id                         OUT RNSP_STATE.RNSPS_ID%TYPE)
    IS
    BEGIN
        IF p_RNSPS_ID IS NULL
        THEN
            INSERT INTO RNSP_STATE (RNSPS_RNSPM,
                                    RNSPS_RNSPA,
                                    /* RNSPS_RNSPA1,
                                     RNSPS_RNSPA2,
                                     RNSPS_RNSPA3,
                                     RNSPS_RNSPA4,*/
                                    RNSPS_NUMIDENT,
                                    RNSPS_IS_NUMIDENT_MISSING,
                                    RNSPS_PASS_SERIA,
                                    RNSPS_PASS_NUM,
                                    RNSPS_LAST_NAME,
                                    RNSPS_FIRST_NAME,
                                    RNSPS_MIDDLE_NAME,
                                    RNSPS_GENDER,
                                    RNSPS_DATE_BIRTH,
                                    RNSPS_NC,
                                    RNSPS_RNSPO,
                                    RNSPS_HS,
                                    HISTORY_STATUS,
                                    RNSPS_OWNERSHIP,
                                    RNSPS_EDR_STATE)
                 VALUES (p_RNSPS_RNSPM,
                         p_RNSPS_RNSPA,
                         /* p_RNSPS_RNSPA1,
                          p_RNSPS_RNSPA2,
                          p_RNSPS_RNSPA3,
                          p_RNSPS_RNSPA4,*/
                         p_RNSPS_NUMIDENT,
                         p_RNSPS_IS_NUMIDENT_MISSING,
                         UPPER (p_RNSPS_PASS_SERIA),
                         p_RNSPS_PASS_NUM,
                         p_RNSPS_LAST_NAME,
                         p_RNSPS_FIRST_NAME,
                         p_RNSPS_MIDDLE_NAME,
                         p_RNSPS_GENDER,
                         p_RNSPS_DATE_BIRTH,
                         p_RNSPS_NC,
                         p_RNSPS_RNSPO,
                         p_RNSPS_HS,
                         p_HISTORY_STATUS,
                         p_RNSPS_OWNERSHIP,
                         p_RNSPS_EDR_STATE)
              RETURNING RNSPS_ID
                   INTO p_new_id;
        ELSE
            p_new_id := p_RNSPS_ID;

            UPDATE RNSP_STATE
               SET RNSPS_RNSPM = p_RNSPS_RNSPM,
                   RNSPS_RNSPA = p_RNSPS_RNSPA,
                   RNSPS_NUMIDENT = p_RNSPS_NUMIDENT,
                   RNSPS_IS_NUMIDENT_MISSING = p_RNSPS_IS_NUMIDENT_MISSING,
                   RNSPS_PASS_SERIA = p_RNSPS_PASS_SERIA,
                   RNSPS_PASS_NUM = p_RNSPS_PASS_NUM,
                   RNSPS_LAST_NAME = p_RNSPS_LAST_NAME,
                   RNSPS_FIRST_NAME = p_RNSPS_FIRST_NAME,
                   RNSPS_MIDDLE_NAME = p_RNSPS_MIDDLE_NAME,
                   RNSPS_GENDER = p_RNSPS_GENDER,
                   RNSPS_DATE_BIRTH = p_RNSPS_DATE_BIRTH,
                   RNSPS_NC = p_RNSPS_NC,
                   RNSPS_RNSPO = p_RNSPS_RNSPO,
                   RNSPS_HS = p_RNSPS_HS,
                   HISTORY_STATUS = p_HISTORY_STATUS,
                   RNSPS_OWNERSHIP = p_RNSPS_OWNERSHIP,
                   RNSPS_EDR_STATE = p_RNSPS_EDR_STATE
             WHERE RNSPS_ID = p_RNSPS_ID;
        END IF;
    END;
END PRIV$RNSP_STATE;
/