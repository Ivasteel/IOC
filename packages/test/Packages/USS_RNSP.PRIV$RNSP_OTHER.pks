/* Formatted on 8/12/2025 5:57:57 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_RNSP.PRIV$RNSP_OTHER
IS
    -- Отримати запис по ідентифікатору
    PROCEDURE Get (p_id IN RNSP_OTHER.RNSPO_ID%TYPE, p_res OUT SYS_REFCURSOR);

    -- Зберегти
    PROCEDURE Save (
        p_RNSPO_ID                 IN     RNSP_OTHER.RNSPO_ID%TYPE,
        p_RNSPO_PROP_FORM          IN     RNSP_OTHER.RNSPO_PROP_FORM%TYPE,
        p_RNSPO_UNION_TP           IN     RNSP_OTHER.RNSPO_UNION_TP%TYPE,
        p_RNSPO_PHONE              IN     RNSP_OTHER.RNSPO_PHONE%TYPE,
        p_RNSPO_EMAIL              IN     RNSP_OTHER.RNSPO_EMAIL%TYPE,
        p_RNSPO_WEB                IN     RNSP_OTHER.RNSPO_WEB%TYPE,
        p_RNSPO_SERVICE_LOCATION   IN     RNSP_OTHER.RNSPO_SERVICE_LOCATION%TYPE,
        p_new_id                      OUT RNSP_OTHER.RNSPO_ID%TYPE);

    -- Вилучити
    PROCEDURE Delete (p_id RNSP_OTHER.RNSPO_ID%TYPE);


    -- Запис не змінився
    FUNCTION IsNoChanges (
        p_RNSPO_ID                 IN RNSP_OTHER.RNSPO_ID%TYPE,
        p_RNSPO_PROP_FORM          IN RNSP_OTHER.RNSPO_PROP_FORM%TYPE,
        p_RNSPO_UNION_TP           IN RNSP_OTHER.RNSPO_UNION_TP%TYPE,
        p_RNSPO_PHONE              IN RNSP_OTHER.RNSPO_PHONE%TYPE,
        p_RNSPO_EMAIL              IN RNSP_OTHER.RNSPO_EMAIL%TYPE,
        p_RNSPO_WEB                IN RNSP_OTHER.RNSPO_WEB%TYPE,
        p_RNSPO_SERVICE_LOCATION   IN RNSP_OTHER.RNSPO_SERVICE_LOCATION%TYPE)
        RETURN BOOLEAN;
END PRIV$RNSP_OTHER;
/


/* Formatted on 8/12/2025 5:58:02 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_RNSP.PRIV$RNSP_OTHER
IS
    -- Отримати запис по ідентифікатору
    PROCEDURE Get (p_id IN RNSP_OTHER.RNSPO_ID%TYPE, p_res OUT SYS_REFCURSOR)
    IS
    BEGIN
        OPEN p_res FOR SELECT RNSPO_PROP_FORM,
                              RNSPO_UNION_TP,
                              RNSPO_ID,
                              RNSPO_PHONE,
                              RNSPO_EMAIL,
                              RNSPO_WEB,
                              RNSPO_SERVICE_LOCATION
                         FROM RNSP_OTHER
                        WHERE RNSPO_ID = p_id;
    END;

    -- Зберегти
    PROCEDURE Save (
        p_RNSPO_ID                 IN     RNSP_OTHER.RNSPO_ID%TYPE,
        p_RNSPO_PROP_FORM          IN     RNSP_OTHER.RNSPO_PROP_FORM%TYPE,
        p_RNSPO_UNION_TP           IN     RNSP_OTHER.RNSPO_UNION_TP%TYPE,
        p_RNSPO_PHONE              IN     RNSP_OTHER.RNSPO_PHONE%TYPE,
        p_RNSPO_EMAIL              IN     RNSP_OTHER.RNSPO_EMAIL%TYPE,
        p_RNSPO_WEB                IN     RNSP_OTHER.RNSPO_WEB%TYPE,
        p_RNSPO_SERVICE_LOCATION   IN     RNSP_OTHER.RNSPO_SERVICE_LOCATION%TYPE,
        p_new_id                      OUT RNSP_OTHER.RNSPO_ID%TYPE)
    IS
    BEGIN
        IF p_RNSPO_ID IS NULL
        THEN
            INSERT INTO RNSP_OTHER (RNSPO_PROP_FORM,
                                    RNSPO_UNION_TP,
                                    RNSPO_PHONE,
                                    RNSPO_EMAIL,
                                    RNSPO_WEB,
                                    RNSPO_SERVICE_LOCATION)
                 VALUES (p_RNSPO_PROP_FORM,
                         p_RNSPO_UNION_TP,
                         p_RNSPO_PHONE,
                         p_RNSPO_EMAIL,
                         p_RNSPO_WEB,
                         p_RNSPO_SERVICE_LOCATION)
              RETURNING RNSPO_ID
                   INTO p_new_id;
        ELSE
            p_new_id := p_RNSPO_ID;

            UPDATE RNSP_OTHER
               SET RNSPO_PROP_FORM = p_RNSPO_PROP_FORM,
                   RNSPO_UNION_TP = p_RNSPO_UNION_TP,
                   RNSPO_PHONE = p_RNSPO_PHONE,
                   RNSPO_EMAIL = p_RNSPO_EMAIL,
                   RNSPO_WEB = p_RNSPO_WEB,
                   RNSPO_SERVICE_LOCATION = p_RNSPO_SERVICE_LOCATION
             WHERE RNSPO_ID = p_RNSPO_ID;
        END IF;
    END;

    -- Вилучити
    PROCEDURE Delete (p_id RNSP_OTHER.RNSPO_ID%TYPE)
    IS
    BEGIN
        DELETE FROM RNSP_OTHER
              WHERE RNSPO_ID = p_id;
    END;

    -- Запис не змінився
    FUNCTION IsNoChanges (
        p_RNSPO_ID                 IN RNSP_OTHER.RNSPO_ID%TYPE,
        p_RNSPO_PROP_FORM          IN RNSP_OTHER.RNSPO_PROP_FORM%TYPE,
        p_RNSPO_UNION_TP           IN RNSP_OTHER.RNSPO_UNION_TP%TYPE,
        p_RNSPO_PHONE              IN RNSP_OTHER.RNSPO_PHONE%TYPE,
        p_RNSPO_EMAIL              IN RNSP_OTHER.RNSPO_EMAIL%TYPE,
        p_RNSPO_WEB                IN RNSP_OTHER.RNSPO_WEB%TYPE,
        p_RNSPO_SERVICE_LOCATION   IN RNSP_OTHER.RNSPO_SERVICE_LOCATION%TYPE)
        RETURN BOOLEAN
    IS
        l_rec   RNSP_OTHER%ROWTYPE;
    BEGIN
        SELECT *
          INTO l_rec
          FROM RNSP_OTHER
         WHERE rnspo_id = p_rnspo_id;

        RETURN (    tools.isequalS (p_RNSPO_PROP_FORM, l_rec.RNSPO_PROP_FORM)
                AND tools.isequalS (p_RNSPO_UNION_TP, l_rec.RNSPO_UNION_TP)
                AND tools.isequalS (p_RNSPO_PHONE, l_rec.RNSPO_PHONE)
                AND tools.isequalS (p_RNSPO_EMAIL, l_rec.RNSPO_EMAIL)
                AND tools.isequalS (p_RNSPO_WEB, l_rec.RNSPO_WEB)
                AND tools.isequalS (p_RNSPO_SERVICE_LOCATION,
                                    l_rec.RNSPO_SERVICE_LOCATION));
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            RETURN FALSE;
    END;
END PRIV$RNSP_OTHER;
/