/* Formatted on 8/12/2025 5:56:53 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_PERSON.API$FEATURE
IS
    -- Author  : SHOSTAK
    -- Created : 11.08.2022 8:18:48 PM
    -- Purpose : Встановлення та перерахунок соціальних статусів

    c_Feature_Tp_Alone       CONSTANT VARCHAR2 (10) := 'ALONE';
    c_Feature_Tp_Large_Fam   CONSTANT VARCHAR2 (10) := 'LFAM';
    c_Feature_Tp_Needy       CONSTANT VARCHAR2 (10) := 'NEEDY';
    c_Feature_Tp_Migrant     CONSTANT VARCHAR2 (10) := 'MIGR';

    c_War_Start_Dt                    DATE
        := TO_DATE ('24.02.2022', 'dd.mm.yyyy');

    --Типи документів, що містять інформацію про інвалідність
    c_Ndt_Msec               CONSTANT NUMBER := 201;
    c_Ndt_Inv_Asopd          CONSTANT NUMBER := 10041;
    c_Ndt_Ppp                CONSTANT NUMBER := 601;
    c_Ndt_Epp                CONSTANT NUMBER := 602;
    --Типи документів, що містять інформацію про одиноких батьків
    c_Ndt_Alone_Asopd        CONSTANT NUMBER := 10105;
    --Типи документів, що містять інформацію про малозабезпечених
    c_Ndt_Needy_Asopd        CONSTANT NUMBER := 10106;
    --Типи документів, що містять інформацію про багатодітну родину
    c_Ndt_l_Fam_Asopd        CONSTANT NUMBER := 10104;
    c_Ndt_l_Fam_Parent       CONSTANT NUMBER := 10108;
    c_Ndt_l_Fam_Child        CONSTANT NUMBER := 10107;
    --Типи жокумів, що містять інформацію про статус ВПО
    c_Ndt_Vpo                CONSTANT NUMBER := 10052;

    TYPE r_Ndt2feature IS RECORD
    (
        Feature_Tp               VARCHAR2 (10),
        Ndt_Id                   NUMBER,
        Weight                   NUMBER,
        Nda_Class_Assign_Dt      VARCHAR2 (10),
        Nda_Class_Till_Dt        VARCHAR2 (10),
        Nda_Class_Till_Dt_Alt    VARCHAR2 (10)
    );

    TYPE t_Ndt2feature IS TABLE OF r_Ndt2feature;

    PROCEDURE Set_Sc_Feature (p_Scs_Sc        IN Sc_Disability.Scy_Sc%TYPE,
                              p_Scs_Scd       IN Sc_Disability.Scy_Scd%TYPE,
                              p_Scs_Scd_Ndt   IN NUMBER DEFAULT NULL,
                              p_Scs_Scd_Dh    IN NUMBER DEFAULT NULL);

    PROCEDURE Unset_Sc_Feature (p_Scs_Sc        IN Sc_Disability.Scy_Sc%TYPE,
                                p_Scs_Scd       IN Sc_Disability.Scy_Scd%TYPE,
                                p_Scs_Scd_Ndt   IN NUMBER DEFAULT NULL,
                                p_Scs_Scd_Dh    IN NUMBER DEFAULT NULL);

    PROCEDURE Set_Sc_Disability (p_Scy_Sc        IN Sc_Disability.Scy_Sc%TYPE,
                                 p_Scy_Scd       IN Sc_Disability.Scy_Scd%TYPE,
                                 p_Scy_Scd_Ndt   IN NUMBER DEFAULT NULL,
                                 p_Scy_Scd_Dh    IN NUMBER DEFAULT NULL);

    PROCEDURE Recalc_Disability_Feature (p_Scd_Id IN NUMBER);

    PROCEDURE Recalc_Features;

    PROCEDURE Set_Sc_Death (p_Sc_Id      IN NUMBER,
                            p_Scd_Id     IN NUMBER,
                            p_Death_Dt   IN DATE,
                            p_Note       IN VARCHAR2,
                            p_Src        IN VARCHAR2,
                            p_Src_Dt     IN DATE);

    PROCEDURE Unset_Sc_Death (p_Sc_Id    IN NUMBER,
                              p_Scd_Id   IN NUMBER,
                              p_Src      IN VARCHAR2,
                              p_Src_Dt   IN DATE);
END Api$feature;
/


GRANT EXECUTE ON USS_PERSON.API$FEATURE TO II01RC_USS_PERSON_INT
/

GRANT EXECUTE ON USS_PERSON.API$FEATURE TO USS_ESR
/

GRANT EXECUTE ON USS_PERSON.API$FEATURE TO USS_EXCH
/

GRANT EXECUTE ON USS_PERSON.API$FEATURE TO USS_RNSP
/

GRANT EXECUTE ON USS_PERSON.API$FEATURE TO USS_RPT
/

GRANT EXECUTE ON USS_PERSON.API$FEATURE TO USS_VISIT
/


/* Formatted on 8/12/2025 5:56:56 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_PERSON.API$FEATURE
IS
    g_Ndt2feature   t_Ndt2feature;

    PROCEDURE Check_Jobs_Terminated
    IS
    BEGIN
        IF Ikis_Sys.Ikis_Parameter_Util.Getparameter1 ('APP_JOBS_STOP',
                                                       'IKIS_SYS') !=
           'FALSE'
        THEN
            Raise_Application_Error (-20000, 'Виконання джобів призупинено');
        END IF;
    END;

    --=============================================================
    --              ЗАГАЛЬНІ СОЦІАЛЬНІ СТАТУСИ
    --=============================================================
    ---------------------------------------------------------------
    --Таблиця звязків між соц. статусом та типом документа
    --+ вага типу документа як джерела інформації про соц. статус
    --TODO: якщо приживеться перенсти в таблицю налаштувань
    ---------------------------------------------------------------
    PROCEDURE Init_Ndt2feature
    IS
        PROCEDURE Add_Ndt2feature (
            p_Feature_Tp              IN VARCHAR2,
            p_Ndt_Id                  IN NUMBER,
            p_Weight                  IN NUMBER,
            p_Nda_Class_Assign_Dt     IN VARCHAR2,
            p_Nda_Class_Till_Dt       IN VARCHAR2,
            p_Nda_Class_Till_Dt_Alt   IN VARCHAR2 DEFAULT NULL)
        IS
        BEGIN
            g_Ndt2feature.EXTEND ();
            g_Ndt2feature (g_Ndt2feature.COUNT).Feature_Tp := p_Feature_Tp;
            g_Ndt2feature (g_Ndt2feature.COUNT).Ndt_Id := p_Ndt_Id;
            g_Ndt2feature (g_Ndt2feature.COUNT).Weight := p_Weight;
            g_Ndt2feature (g_Ndt2feature.COUNT).Nda_Class_Assign_Dt :=
                p_Nda_Class_Assign_Dt;
            g_Ndt2feature (g_Ndt2feature.COUNT).Nda_Class_Till_Dt :=
                p_Nda_Class_Till_Dt;
            g_Ndt2feature (g_Ndt2feature.COUNT).Nda_Class_Till_Dt_Alt :=
                p_Nda_Class_Till_Dt_Alt;
        END;
    BEGIN
        IF g_Ndt2feature IS NULL
        THEN
            g_Ndt2feature := t_Ndt2feature ();

            Add_Ndt2feature (c_Feature_Tp_Alone,
                             c_Ndt_Alone_Asopd,
                             1,
                             'ASDT',
                             'TILLDT');
            Add_Ndt2feature (c_Feature_Tp_Needy,
                             c_Ndt_Needy_Asopd,
                             1,
                             'ASDT',
                             'TILLDT');
            Add_Ndt2feature (c_Feature_Tp_Large_Fam,
                             c_Ndt_l_Fam_Asopd,
                             2,
                             'ASDT',
                             'TILLDT');
            Add_Ndt2feature (c_Feature_Tp_Large_Fam,
                             c_Ndt_l_Fam_Parent,
                             1,
                             'DGVDT',
                             'DSPDT',
                             'TILLDT');
            Add_Ndt2feature (c_Feature_Tp_Large_Fam,
                             c_Ndt_l_Fam_Child,
                             1,
                             'DGVDT',
                             'DSPDT',
                             'TILLDT');
            Add_Ndt2feature (c_Feature_Tp_Migrant,
                             c_Ndt_Vpo,
                             1,
                             'DGVDT',
                             'TILLDT');
        END IF;
    END;

    ---------------------------------------------------------------
    --Отримання інформації про cоціальний статус
    -- з атрибутів документа
    ---------------------------------------------------------------
    FUNCTION Dh2feature_Info (p_Dh_Id         IN NUMBER,
                              p_Ndt2feature   IN r_Ndt2feature)
        RETURN Sc_Feature_Hist%ROWTYPE
    IS
        l_Scs   Sc_Feature_Hist%ROWTYPE;
    BEGIN
        SELECT MAX (
                   CASE
                       WHEN n.Nda_Class = p_Ndt2feature.Nda_Class_Assign_Dt
                       THEN
                           a.Da_Val_Dt
                   END),
               NVL (
                   MAX (
                       CASE
                           WHEN n.Nda_Class = p_Ndt2feature.Nda_Class_Till_Dt
                           THEN
                               a.Da_Val_Dt
                       END),
                   CASE
                       WHEN p_Ndt2feature.Nda_Class_Till_Dt_Alt IS NOT NULL
                       THEN
                           MAX (
                               CASE
                                   WHEN n.Nda_Class =
                                        p_Ndt2feature.Nda_Class_Till_Dt_Alt
                                   THEN
                                       a.Da_Val_Dt
                               END)
                   END)
          INTO l_Scs.Scs_Assign_Dt, l_Scs.Scs_Till_Dt
          FROM Uss_Doc.v_Doc_Attr2hist  h
               JOIN Uss_Doc.v_Doc_Attributes a ON h.Da2h_Da = a.Da_Id
               JOIN Uss_Ndi.v_Ndi_Document_Attr n ON a.Da_Nda = n.Nda_Id
         WHERE h.Da2h_Dh = p_Dh_Id;

        IF l_Scs.Scs_Till_Dt IS NULL
        THEN
            l_Scs.Scs_Till_Dt := TO_DATE ('01.01.2099', 'dd.mm.yyyy');
        END IF;

        RETURN l_Scs;
    END;

    PROCEDURE Lock_Feature (p_Sc_Id IN NUMBER, p_Feature_Tp IN VARCHAR2)
    IS
        l_Scs_Id   NUMBER;
    BEGIN
        SELECT Scs_Id
          INTO l_Scs_Id
          FROM Sc_Feature_Hist h
         WHERE     h.Scs_Sc = p_Sc_Id
               AND h.Scs_Tp = p_Feature_Tp
               AND h.History_Status = 'A'
        FOR UPDATE;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            NULL;
    END;

    PROCEDURE Save_Feature (p_Scf_Id       IN NUMBER,
                            p_Scf_Sc       IN NUMBER,
                            p_Feature_Tp   IN VARCHAR2,
                            p_Val          IN VARCHAR2)
    IS
        l_Scf_Id   NUMBER;
    BEGIN
        Api$socialcard.Save_Sc_Feature (
            p_Scf_Id           => p_Scf_Id,
            p_Scf_Sc           => p_Scf_Sc,
            p_Scf_Is_Singl_Parent   =>
                CASE WHEN p_Feature_Tp = c_Feature_Tp_Alone THEN p_Val END,
            p_Scf_Is_Large_Family   =>
                CASE
                    WHEN p_Feature_Tp = c_Feature_Tp_Large_Fam THEN p_Val
                END,
            p_Scf_Is_Low_Income   =>
                CASE WHEN p_Feature_Tp = c_Feature_Tp_Needy THEN p_Val END,
            p_Scf_Is_Migrant   =>
                CASE WHEN p_Feature_Tp = c_Feature_Tp_Migrant THEN p_Val END,
            p_New_Id           => l_Scf_Id);
    END;

    ---------------------------------------------------------------
    --Встановлення соціального статусу на підставі документу
    ---------------------------------------------------------------
    PROCEDURE Set_Sc_Feature (p_Scs_Sc        IN Sc_Disability.Scy_Sc%TYPE,
                              p_Scs_Scd       IN Sc_Disability.Scy_Scd%TYPE,
                              p_Scs_Scd_Ndt   IN NUMBER DEFAULT NULL,
                              p_Scs_Scd_Dh    IN NUMBER DEFAULT NULL)
    IS
        l_Scd_Ndt_New   NUMBER;
        l_Scd_Dh_New    NUMBER;

        FUNCTION Get_Scd_Weight (p_Scd_Ndt NUMBER)
            RETURN NUMBER
        IS
            l_Weight   NUMBER;
        BEGIN
            SELECT Weight
              INTO l_Weight
              FROM TABLE (g_Ndt2feature)
             WHERE Ndt_Id = p_Scd_Ndt;

            RETURN l_Weight;
        END;
    BEGIN
        --Отримуємо документ, що є новим джерелом інформації про соціальний статус
        IF p_Scs_Scd_Ndt IS NULL OR p_Scs_Scd_Dh IS NULL
        THEN
            SELECT d.Scd_Ndt, d.Scd_Dh
              INTO l_Scd_Ndt_New, l_Scd_Dh_New
              FROM Sc_Document d
             WHERE d.Scd_Id = p_Scs_Scd;
        ELSE
            l_Scd_Ndt_New := p_Scs_Scd_Ndt;
            l_Scd_Dh_New := p_Scs_Scd_Dh;
        END IF;

        --Отримуємо перелік соціальних статусів що визначаются за вказаним типом документа
        FOR Rec IN (SELECT *
                      FROM TABLE (g_Ndt2feature)
                     WHERE Ndt_Id = l_Scd_Ndt_New)
        LOOP
            DECLARE
                l_Scd_Ndt_Old    NUMBER;
                l_Scd_Dh_Old     NUMBER;

                l_Scs            Sc_Feature_Hist%ROWTYPE;

                l_Is_First_Rec   NUMBER;
                l_Scf_Id         NUMBER;
            BEGIN
                --Отримуємо нову інформацію про соціальний зі зрізу документа
                l_Scs :=
                    Dh2feature_Info (p_Dh_Id         => l_Scd_Dh_New,
                                     p_Ndt2feature   => Rec);
                l_Scs.Scs_Scd := p_Scs_Scd;

                IF    l_Scs.Scs_Till_Dt < TRUNC (SYSDATE)
                   OR l_Scs.Scs_Assign_Dt > TRUNC (SYSDATE)
                THEN
                    RETURN;
                END IF;

                Lock_Feature (p_Scs_Sc, Rec.Feature_Tp);

                --Отримуємо документ, що є поточним джерелом інформації про соціальний статус
                SELECT MAX (d.Scd_Ndt), MAX (d.Scd_Dh)
                  INTO l_Scd_Ndt_Old, l_Scd_Dh_Old
                  FROM Sc_Feature_Hist  h
                       JOIN Sc_Document d ON h.Scs_Scd = d.Scd_Id
                 WHERE     h.Scs_Sc = p_Scs_Sc
                       AND h.Scs_Tp = Rec.Feature_Tp
                       AND h.History_Status = 'A';

                --Якщо вже існує актуальна інформація про соціальний статус в соцкартці
                IF l_Scd_Ndt_Old IS NOT NULL
                THEN
                    l_Is_First_Rec := 0;

                    --Якщо приорітет джерела нових даних більше або дорівнює приорітету джерела поточних даних
                    IF     Rec.Weight >= Get_Scd_Weight (l_Scd_Ndt_Old)
                       --та нові дані відрізняюья від старих,
                       --тоді переводимо поточні дані в історичний статус
                       AND l_Scd_Dh_New <> l_Scd_Dh_Old
                    THEN
                        UPDATE Sc_Feature_Hist d
                           SET d.History_Status = 'H',
                               d.Scs_Stop_Dt = SYSDATE
                         WHERE     d.Scs_Sc = p_Scs_Sc
                               AND d.Scs_Tp = Rec.Feature_Tp
                               AND d.History_Status = 'A';
                    ELSE
                        RETURN;
                    END IF;
                ELSE
                    SELECT DECODE (COUNT (*), 0, 1, 0)
                      INTO l_Is_First_Rec
                      FROM Sc_Feature_Hist h
                     WHERE h.Scs_Sc = p_Scs_Sc AND h.Scs_Tp = Rec.Feature_Tp;
                END IF;

                --Встановлюємо період дії соціального статусу
                Api$socialcard.Save_Sc_Feature_Hist (
                    p_Scs_Sc           => p_Scs_Sc,
                    p_Scs_Tp           => Rec.Feature_Tp,
                    p_Scs_Scd          => p_Scs_Scd,
                    p_Scs_Start_Dt     =>
                        CASE
                            WHEN l_Is_First_Rec = 1
                            THEN
                                TO_DATE ('01.01.2022', 'dd.mm.yyyy')
                            ELSE
                                SYSDATE
                        END,
                    p_Scs_Stop_Dt      => NULL,
                    p_Scs_Assign_Dt    => l_Scs.Scs_Assign_Dt,
                    p_Scs_Till_Dt      => l_Scs.Scs_Till_Dt,
                    p_Scs_Dh           => l_Scd_Dh_New,
                    p_History_Status   => 'A');

                l_Scf_Id := Api$socialcard.Get_Sc_Scf (p_Scs_Sc);
                --Встановлюємо соціальний статус
                Save_Feature (p_Scf_Id       => l_Scf_Id,
                              p_Scf_Sc       => p_Scs_Sc,
                              p_Feature_Tp   => Rec.Feature_Tp,
                              p_Val          => 'T');
            END;
        END LOOP;
    END;

    ---------------------------------------------------------------
    --Зняття соціального статусу на підставі документу
    ---------------------------------------------------------------
    PROCEDURE Unset_Sc_Feature (p_Scs_Sc        IN Sc_Disability.Scy_Sc%TYPE,
                                p_Scs_Scd       IN Sc_Disability.Scy_Scd%TYPE,
                                p_Scs_Scd_Ndt   IN NUMBER DEFAULT NULL,
                                p_Scs_Scd_Dh    IN NUMBER DEFAULT NULL)
    IS
        l_Scd_Ndt_New   NUMBER;
        l_Scd_Dh_New    NUMBER;
    BEGIN
        --Отримуємо документ, що є новим джерелом інформації про соціальний статус
        IF p_Scs_Scd_Ndt IS NULL OR p_Scs_Scd_Dh IS NULL
        THEN
            SELECT d.Scd_Ndt, d.Scd_Dh
              INTO l_Scd_Ndt_New, l_Scd_Dh_New
              FROM Sc_Document d
             WHERE d.Scd_Id = p_Scs_Scd;
        ELSE
            l_Scd_Ndt_New := p_Scs_Scd_Ndt;
            l_Scd_Dh_New := p_Scs_Scd_Dh;
        END IF;

        --Отримуємо перелік соціальних статусів що визначаются за вказаним типом документа
        FOR Rec IN (SELECT *
                      FROM TABLE (g_Ndt2feature)
                     WHERE Ndt_Id = l_Scd_Ndt_New)
        LOOP
            DECLARE
                l_Scs      Sc_Feature_Hist%ROWTYPE;
                l_Scf_Id   NUMBER;
            BEGIN
                --Отримуємо нову інформацію про соціальний зі зрізу документа
                l_Scs :=
                    Dh2feature_Info (p_Dh_Id         => l_Scd_Dh_New,
                                     p_Ndt2feature   => Rec);
                l_Scf_Id := Api$socialcard.Get_Sc_Scf (p_Scs_Sc);

                --Знімаємо соціальний статус
                UPDATE Sc_Feature_Hist h
                   SET h.History_Status = 'A',
                       h.Scs_Stop_Dt = SYSDATE,
                       h.Scs_Till_Dt = l_Scs.Scs_Till_Dt
                 WHERE     h.Scs_Sc = p_Scs_Sc
                       AND h.Scs_Tp = Rec.Feature_Tp
                       AND h.History_Status = 'A'
                       AND h.Scs_Scd = p_Scs_Scd;

                Save_Feature (p_Scf_Id       => l_Scf_Id,
                              p_Scf_Sc       => p_Scs_Sc,
                              p_Feature_Tp   => Rec.Feature_Tp,
                              p_Val          => 'F');
            END;
        END LOOP;
    END;

    ---------------------------------------------------------------
    --  Масовий перерахунок загальних ознак в соціальних картках
    ---------------------------------------------------------------
    PROCEDURE Recalc_Common_Features
    IS
        l_Iter   NUMBER := 0;

        --Отримання інформації про соціальний статус з атрибутів документа
        FUNCTION Scd2feature_Info (p_Scd_Sc        IN NUMBER,
                                   p_Ndt2feature   IN r_Ndt2feature)
            RETURN Sc_Feature_Hist%ROWTYPE
        IS
            l_Scs      Sc_Feature_Hist%ROWTYPE;
            l_Scd_Id   NUMBER;
            l_Dh_Id    NUMBER;
        BEGIN
              SELECT c.Scd_Id, c.Scd_Dh
                INTO l_Scd_Id, l_Dh_Id
                FROM Uss_Person.Sc_Document c
               WHERE     c.Scd_Sc = p_Scd_Sc
                     AND c.Scd_Ndt = p_Ndt2feature.Ndt_Id
                     AND c.Scd_St = '1'
            ORDER BY c.Scd_Id DESC
               FETCH FIRST ROW ONLY;

            l_Scs := Dh2feature_Info (l_Dh_Id, p_Ndt2feature);
            l_Scs.Scs_Scd := l_Scd_Id;
            l_Scs.Scs_Dh := l_Dh_Id;
            l_Scs.Scs_Tp := p_Ndt2feature.Feature_Tp;
            RETURN l_Scs;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                RETURN l_Scs;
        END;
    BEGIN
        --Цикл по всіх соціальних статусах, для яких завершено період дії
        FOR Scs
            IN (SELECT h.*, f.Scf_Id
                  FROM Sc_Feature_Hist  h
                       JOIN Sc_Feature f ON h.Scs_Sc = f.Scf_Sc
                 WHERE     h.History_Status = 'A'
                       AND h.Scs_Till_Dt < TRUNC (SYSDATE))
        LOOP
            DECLARE
                l_Feature_Enabled   BOOLEAN := FALSE;
                l_Scs               Sc_Feature_Hist%ROWTYPE;
            BEGIN
                Check_Jobs_Terminated;

                Lock_Feature (Scs.Scs_Sc, Scs.Scs_Tp);

                --Вираховуємо чи є якийсь інший документ, що підтверджує соціальний статус на поточну дату
                FOR Ndt2feature IN (  SELECT *
                                        FROM TABLE (g_Ndt2feature)
                                       WHERE Feature_Tp = Scs.Scs_Tp
                                    ORDER BY Weight DESC)
                LOOP
                    l_Scs := Scd2feature_Info (Scs.Scs_Sc, Ndt2feature);
                    l_Feature_Enabled :=
                        NVL (
                                l_Scs.Scs_Till_Dt > TRUNC (SYSDATE)
                            AND l_Scs.Scs_Assign_Dt <= TRUNC (SYSDATE),
                            FALSE);

                    IF l_Feature_Enabled
                    THEN
                        EXIT;
                    END IF;
                END LOOP;

                IF NOT l_Feature_Enabled
                THEN
                    --Знімаємо соціальний статус
                    Save_Feature (p_Scf_Id       => Scs.Scf_Id,
                                  p_Scf_Sc       => Scs.Scs_Sc,
                                  p_Feature_Tp   => Scs.Scs_Tp,
                                  p_Val          => 'F');
                ELSE
                    --Зберігаємо новий період дії соціального статуса, та посилання на документ на підставі якого його встановлено
                    Api$socialcard.Save_Sc_Feature_Hist (
                        p_Scs_Sc           => Scs.Scs_Sc,
                        p_Scs_Tp           => Scs.Scs_Tp,
                        p_Scs_Scd          => l_Scs.Scs_Scd,
                        p_Scs_Start_Dt     => SYSDATE,
                        p_Scs_Stop_Dt      => NULL,
                        p_Scs_Assign_Dt    => l_Scs.Scs_Assign_Dt,
                        p_Scs_Till_Dt      => l_Scs.Scs_Till_Dt,
                        p_Scs_Dh           => l_Scs.Scs_Dh,
                        p_History_Status   => 'A');
                END IF;

                --Переводимо поточний період дії соціального статусу в історичний
                UPDATE Sc_Feature_Hist h
                   SET h.History_Status = 'H', h.Scs_Stop_Dt = SYSDATE
                 WHERE h.Scs_Id = Scs.Scs_Id;

                IF MOD (l_Iter, 500) = 0
                THEN
                    COMMIT;
                END IF;

                l_Iter := l_Iter + 1;
            END;
        END LOOP;
    END;

    --=============================================================
    --                      ІНВАЛІДНІСТЬ
    --=============================================================
    ---------------------------------------------------------------
    --Отримання інформації про інвалідність з атрибутів документа
    ---------------------------------------------------------------
    FUNCTION Dh2disability (p_Dh_Id IN NUMBER)
        RETURN Sc_Disability%ROWTYPE
    IS
        l_Scy   Sc_Disability%ROWTYPE;
    BEGIN
        SELECT MAX (CASE WHEN n.Nda_Class = 'INVGR' THEN a.Da_Val_String END),
               MAX (CASE WHEN n.Nda_Class = 'INSPDT' THEN a.Da_Val_Dt END),
               MAX (CASE WHEN n.Nda_Class = 'INVSTDT' THEN a.Da_Val_Dt END),
               MAX (CASE WHEN n.Nda_Class = 'INVSPDT' THEN a.Da_Val_Dt END),
               MAX (CASE WHEN n.Nda_Class = 'INVRN' THEN a.Da_Val_String END)
          INTO l_Scy.Scy_Group,
               l_Scy.Scy_Inspection_Dt,
               l_Scy.Scy_Decision_Dt,
               l_Scy.Scy_Till_Dt,
               l_Scy.Scy_Reason
          FROM Uss_Doc.v_Doc_Attr2hist  h
               JOIN Uss_Doc.v_Doc_Attributes a ON h.Da2h_Da = a.Da_Id
               JOIN Uss_Ndi.v_Ndi_Document_Attr n ON a.Da_Nda = n.Nda_Id
         WHERE h.Da2h_Dh = p_Dh_Id;

        IF l_Scy.Scy_Group IS NOT NULL AND l_Scy.Scy_Till_Dt IS NULL
        THEN
            l_Scy.Scy_Till_Dt := TO_DATE ('01.01.2099', 'dd.mm.yyyy');
        END IF;

        RETURN l_Scy;
    END;

    PROCEDURE Lock_Disability (p_Sc_Id NUMBER)
    IS
        l_Scy_Id   NUMBER;
    BEGIN
        SELECT d.Scy_Id
          INTO l_Scy_Id
          FROM Sc_Disability d
         WHERE d.Scy_Sc = p_Sc_Id AND d.History_Status = 'A'
        FOR UPDATE;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            NULL;
    END;

    -------------------------------------------------------
    --  Збереження ознаки та інформації про інвалідність
    -------------------------------------------------------
    PROCEDURE Set_Sc_Disability (p_Scy_Sc        IN Sc_Disability.Scy_Sc%TYPE,
                                 p_Scy_Scd       IN Sc_Disability.Scy_Scd%TYPE,
                                 p_Scy_Scd_Ndt   IN NUMBER DEFAULT NULL,
                                 p_Scy_Scd_Dh    IN NUMBER DEFAULT NULL)
    IS
        l_Scd_Ndt_New    NUMBER;
        l_Scd_Dh_New     NUMBER;

        l_Scd_Ndt_Old    NUMBER;
        l_Scd_Dh_Old     NUMBER;

        l_Scy            Sc_Disability%ROWTYPE;

        l_Is_First_Rec   NUMBER;
        l_Scf_Id         NUMBER;

        l_Scy_Id         Sc_Disability.Scy_Id%TYPE;

        FUNCTION Get_Scd_Weight (p_Scd_Ndt NUMBER)
            RETURN NUMBER
        IS
            l_Weight   NUMBER;
        BEGIN
            SELECT DECODE (p_Scd_Ndt,
                           c_Ndt_Msec, 3,
                           c_Ndt_Inv_Asopd, 2,
                           c_Ndt_Ppp, 1,
                           c_Ndt_Epp, 1)
              INTO l_Weight
              FROM DUAL;

            RETURN l_Weight;
        END;
    BEGIN
        --Отримуємо документ, що є новим джерелом інформації про інвалідність
        IF p_Scy_Scd_Ndt IS NULL OR p_Scy_Scd_Dh IS NULL
        THEN
            SELECT d.Scd_Ndt, d.Scd_Dh
              INTO l_Scd_Ndt_New, l_Scd_Dh_New
              FROM Sc_Document d
             WHERE d.Scd_Id = p_Scy_Scd;
        ELSE
            l_Scd_Ndt_New := p_Scy_Scd_Ndt;
            l_Scd_Dh_New := p_Scy_Scd_Dh;
        END IF;

        l_Scy := Dh2disability (l_Scd_Dh_New);
        l_Scy.Scy_Scd := p_Scy_Scd;

        IF l_Scy.Scy_Group IS NULL
        THEN
            RETURN;
        END IF;

        --Якщо термін дії інвалідності закінчено
        IF     l_Scy.Scy_Till_Dt < TRUNC (SYSDATE)
           --і джерелом інформації не є довідка МСЕК
           AND (   l_Scd_Ndt_New <> c_Ndt_Msec
                OR --або джерелом є довідка МЕСК, яка не була видана у довоєнний час
                   (    l_Scd_Ndt_New = c_Ndt_Msec
                    AND c_War_Start_Dt NOT BETWEEN l_Scy.Scy_Decision_Dt
                                               AND l_Scy.Scy_Till_Dt))
        THEN
            --то не зберігаємо таку інформацію
            RETURN;
        END IF;

        Lock_Disability (p_Scy_Sc);

        --Отримуємо документ, що є поточним джерелом інформації про інвалідність
        SELECT MAX (d.Scd_Ndt), MAX (i.scy_dh), MAX (i.Scy_Id)
          INTO l_Scd_Ndt_Old, l_Scd_Dh_Old, l_Scy_Id
          FROM Sc_Disability  i
               LEFT JOIN Sc_Document d ON i.Scy_Scd = d.Scd_Id --інвалідність підтверджена наявністю пенсії по інвалідності
         WHERE     i.Scy_Sc = p_Scy_Sc
               AND i.History_Status = 'A'
               AND (   d.Scd_Id IS NOT NULL
                    OR (i.Scy_Group IS NULL AND i.Scy_Scd IS NULL));

        --Якщо вже існує актуальна інформація про інвалідність в соцкартці
        IF l_Scd_Ndt_Old IS NOT NULL
        THEN
            l_Is_First_Rec := 0;

            --Якщо приорітет джерела нових даних більше або дорівнює приорітету джерела поточних даних
            IF     Get_Scd_Weight (l_Scd_Ndt_New) >=
                   Get_Scd_Weight (l_Scd_Ndt_Old)
               --та нові дані відрізняюья від старих,
               --тоді переводимо поточні дані в історичний статус
               AND l_Scd_Dh_New <> l_Scd_Dh_Old
            THEN
                UPDATE Sc_Disability d
                   SET d.History_Status = 'H', d.Scy_Stop_Dt = SYSDATE
                 WHERE     d.Scy_Sc = p_Scy_Sc
                       AND d.History_Status = 'A'
                       --за виключенням ситуації, коли виконується спроба зберігти неактуальні дані
                       --(таке можливо, якщо намагаємось у вигляді виключення зберегти дані з довідки МСЕК,
                       --що була видана до початку війни, та термін дії якої було завершено після початку війни.
                       --Але інформація з такої довідки зберігається лишу у випадку, коли у соц. картці
                       --немає поточної актуальної інформації про інвалідність. #78603)
                       AND NOT (    l_Scy.Scy_Till_Dt < TRUNC (SYSDATE)
                                AND d.Scy_Till_Dt > TRUNC (SYSDATE));

                IF SQL%ROWCOUNT = 0
                THEN
                    RETURN;
                END IF;
            ELSE
                RETURN;
            END IF;
        ELSE
            l_Is_First_Rec := 1;
        END IF;

        --Зберігаємо інформацію про інвалідність
        Api$socialcard.Save_Sc_Disability (
            p_Scy_Sc              => p_Scy_Sc,
            p_Scy_Group           => l_Scy.Scy_Group,
            p_Scy_Scd             => l_Scy.Scy_Scd,
            p_Scy_Inspection_Dt   => l_Scy.Scy_Inspection_Dt,
            p_Scy_Decision_Dt     => l_Scy.Scy_Decision_Dt,
            p_Scy_Till_Dt         => l_Scy.Scy_Till_Dt,
            p_Scy_Reason          => l_Scy.Scy_Reason,
            --По постановці І.Павлюкова
            p_Scy_Start_Dt        =>
                CASE
                    WHEN l_Is_First_Rec = 1
                    THEN
                        TO_DATE ('01.01.2022', 'dd.mm.yyyy')
                    ELSE
                        SYSDATE
                END,
            p_Scy_Stop_Dt         => NULL,
            p_Scy_Dh              => l_Scd_Dh_New,
            p_History_Status      => 'A');

        --Переводимо поточний запис з інформацією про інвалідність по пенсії в історичний статус
        IF l_Scy_Id IS NOT NULL
        THEN
            UPDATE Sc_Disability d
               SET d.Scy_Stop_Dt = SYSDATE, d.History_Status = 'H'
             WHERE d.Scy_Id = l_Scy_Id;
        END IF;

        l_Scf_Id := Api$socialcard.Get_Sc_Scf (p_Scy_Sc);
        --Зберігаємо ознаку про інвалідність
        Api$socialcard.Save_Sc_Feature (p_Scf_Id            => l_Scf_Id,
                                        p_Scf_Sc            => p_Scy_Sc,
                                        p_Scf_Is_Dasabled   => 'T',
                                        p_New_Id            => l_Scf_Id);
    END;

    PROCEDURE Recalc_Disability_Feature (
        p_Scy               Sc_Disability%ROWTYPE,
        p_Recalc_Start_Dt   DATE DEFAULT SYSDATE)
    IS
        l_Is_Disabled     BOOLEAN := FALSE;
        l_Scy             Sc_Disability%ROWTYPE;
        l_Dh_Id           NUMBER;
        l_Scd_Ndt         NUMBER;
        l_Scf_Id          NUMBER;
        l_Already_Saved   NUMBER;

        --Отримання інформації про інвалідність з атрибутів документа
        FUNCTION Scd2disability (p_Scd_Sc IN NUMBER, p_Scd_Ndt IN NUMBER)
            RETURN Sc_Disability%ROWTYPE
        IS
            l_Scy      Sc_Disability%ROWTYPE;
            l_Scd_Id   NUMBER;
            l_Dh_Id    NUMBER;
        BEGIN
              SELECT c.Scd_Id, c.Scd_Dh
                INTO l_Scd_Id, l_Dh_Id
                FROM Uss_Person.Sc_Document c
               WHERE     c.Scd_Sc = p_Scd_Sc
                     AND c.Scd_Ndt = p_Scd_Ndt
                     AND c.Scd_St = '1'
            ORDER BY (CASE WHEN c.Scd_Dh IS NOT NULL THEN 0 ELSE 1 END),
                     c.Scd_Issued_Dt DESC,
                     c.Scd_Stop_Dt DESC
               FETCH FIRST 1 ROW ONLY;

            IF l_Dh_Id IS NOT NULL
            THEN
                l_Scy := Dh2disability (l_Dh_Id);
                l_Scy.Scy_Scd := l_Scd_Id;
                l_Scy.Scy_Dh := l_Dh_Id;
            END IF;

            RETURN l_Scy;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                RETURN l_Scy;
        END;
    BEGIN
        Check_Jobs_Terminated;

        Lock_Disability (p_Scy.Scy_Sc);

        SELECT MAX (d.Scd_Ndt)
          INTO l_Scd_Ndt
          FROM Sc_Document d
         WHERE d.Scd_Id = p_Scy.Scy_Scd;

        --Перевірка ознаки за даними ЦБІ
        l_Scy := Scd2disability (p_Scy.Scy_Sc, c_Ndt_Msec);
        l_Is_Disabled :=
            l_Scy.Scy_Group IS NOT NULL AND l_Scy.Scy_Till_Dt > SYSDATE;

        IF NOT l_Is_Disabled
        THEN
            --Перевірка ознаки за даними АСОПД
            l_Scy := Scd2disability (p_Scy.Scy_Sc, c_Ndt_Inv_Asopd);
            l_Is_Disabled :=
                l_Scy.Scy_Group IS NOT NULL AND l_Scy.Scy_Till_Dt > SYSDATE;
        END IF;

        IF NOT l_Is_Disabled
        THEN
            --Перевірка ознаки за даними ПП
            l_Scy := Scd2disability (p_Scy.Scy_Sc, c_Ndt_Ppp);
            l_Is_Disabled :=
                l_Scy.Scy_Group IS NOT NULL AND l_Scy.Scy_Till_Dt > SYSDATE;
        END IF;

        IF NOT l_Is_Disabled
        THEN
            --Перевірка ознаки за даними ЕПП
            l_Scy := Scd2disability (p_Scy.Scy_Sc, c_Ndt_Epp);
            l_Is_Disabled :=
                l_Scy.Scy_Group IS NOT NULL AND l_Scy.Scy_Till_Dt > SYSDATE;
        END IF;

        IF NOT l_Is_Disabled
        THEN
            --#78603/#79791
            IF    (    l_Scd_Ndt = c_Ndt_Msec
                   AND c_War_Start_Dt BETWEEN p_Scy.Scy_Decision_Dt
                                          AND p_Scy.Scy_Till_Dt)
               OR p_Scy.Scy_Scd IS NULL
            THEN
                RETURN;
            END IF;

            l_Scf_Id := Api$socialcard.Get_Sc_Scf (p_Scy.Scy_Sc);
            --Якщо не підтверджено інвалідність на поточну дату у жодному із джерел - змінюємо на F
            Uss_Person.Api$socialcard.Save_Sc_Feature (
                p_Scf_Id            => l_Scf_Id,
                p_Scf_Sc            => p_Scy.Scy_Sc,
                p_Scf_Is_Dasabled   => 'F',
                p_New_Id            => l_Scf_Id);
        ELSE
            SELECT SIGN (COUNT (*))
              INTO l_Already_Saved
              FROM Sc_Disability d
             WHERE d.Scy_Sc = p_Scy.Scy_Sc AND d.Scy_Dh = l_Scy.Scy_Dh;

            --Якщо якийсь інший поток завантажння вже виконав збереження інфалідності по цьому зрізу документа, то скіпаємо
            IF l_Already_Saved = 1
            THEN
                RETURN;
            END IF;

            --Зберігаємо нову інформацію про інвалідність
            Api$socialcard.Save_Sc_Disability (
                p_Scy_Sc              => p_Scy.Scy_Sc,
                p_Scy_Group           => l_Scy.Scy_Group,
                p_Scy_Scd             => l_Scy.Scy_Scd,
                p_Scy_Inspection_Dt   => l_Scy.Scy_Inspection_Dt,
                p_Scy_Decision_Dt     => l_Scy.Scy_Decision_Dt,
                p_Scy_Till_Dt         => l_Scy.Scy_Till_Dt,
                p_Scy_Reason          => l_Scy.Scy_Reason,
                p_Scy_Start_Dt        => p_Recalc_Start_Dt,
                p_Scy_Stop_Dt         => NULL,
                p_Scy_Dh              => l_Scy.Scy_Dh,
                p_History_Status      => 'A');
        END IF;

        --Переводимо поточний запис з інформацією про інвалідність в історичний статус
        UPDATE Sc_Disability d
           SET d.Scy_Stop_Dt = p_Recalc_Start_Dt, d.History_Status = 'H'
         WHERE d.Scy_Id = p_Scy.Scy_Id;
    END;

    PROCEDURE Recalc_Disability_Feature (p_Scd_Id IN NUMBER)
    IS
        l_Scy   Sc_Disability%ROWTYPE;
    BEGIN
        BEGIN
            SELECT d.*
              INTO l_Scy
              FROM Sc_Disability d
             WHERE d.Scy_Scd = p_Scd_Id AND d.History_Status = 'A';
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                RETURN;
        END;

        Recalc_Disability_Feature (l_Scy);
    END;

    -------------------------------------------------------
    --  Масовий перерахунок ознак по інвалідності
    -------------------------------------------------------
    PROCEDURE Recalc_Disability_Features
    IS
        l_Iter      NUMBER := 0;
        v_Curr_Dt   DATE := SYSDATE;

        --Отримання інформації про інвалідність з атрибутів документа
        FUNCTION Scd2disability (p_Scd_Sc IN NUMBER, p_Scd_Ndt IN NUMBER)
            RETURN Sc_Disability%ROWTYPE
        IS
            l_Scy      Sc_Disability%ROWTYPE;
            l_Scd_Id   NUMBER;
            l_Dh_Id    NUMBER;
        BEGIN
              SELECT c.Scd_Id, c.Scd_Dh
                INTO l_Scd_Id, l_Dh_Id
                FROM Uss_Person.Sc_Document c
               WHERE     c.Scd_Sc = p_Scd_Sc
                     AND c.Scd_Ndt = p_Scd_Ndt
                     AND c.Scd_St = '1'
            ORDER BY (CASE WHEN c.Scd_Dh IS NOT NULL THEN 0 ELSE 1 END),
                     c.Scd_Issued_Dt DESC,
                     c.Scd_Stop_Dt DESC
               FETCH FIRST 1 ROW ONLY;

            IF l_Dh_Id IS NOT NULL
            THEN
                l_Scy := Dh2disability (l_Dh_Id);
                l_Scy.Scy_Scd := l_Scd_Id;
                l_Scy.Scy_Dh := l_Dh_Id;
            END IF;

            RETURN l_Scy;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                RETURN l_Scy;
        END;
    BEGIN
        FOR Rec
            IN (SELECT i.*
                  FROM Sc_Feature  f
                       JOIN Sc_Disability i
                           ON f.Scf_Sc = i.Scy_Sc AND i.History_Status = 'A'
                 WHERE     f.Scf_Is_Dasabled = 'T'
                       AND (   i.Scy_Scd IS NULL
                            OR i.Scy_Till_Dt < TRUNC (SYSDATE)))
        LOOP
            Recalc_Disability_Feature (Rec);

            IF MOD (l_Iter, 500) = 0
            THEN
                COMMIT;
            END IF;

            l_Iter := l_Iter + 1;
        END LOOP;

        COMMIT;
        l_Iter := 0;

        --#79791 зняття інвалідності встановленої раніше на основі наявності пенсії по інвалідності
        FOR Rec1
            IN (SELECT f.Scf_Id, f.Scf_Sc, d.Scy_Id
                  FROM Sc_Feature  f
                       JOIN Sc_Disability d
                           ON     d.Scy_Sc = f.Scf_Sc
                              AND d.History_Status = 'A'
                              AND d.Scy_Scd IS NULL
                       LEFT JOIN (SELECT p.Scp_Id,
                                         p.Scp_Sc,
                                         p.Scp_End_Dt,
                                         Pt.Dic_Name     AS Pens_Tp_Name
                                    FROM Sc_Pension  p
                                         JOIN Uss_Ndi.v_Ddn_Scp_Pens_Tp Pt
                                             ON     Pt.Dic_Value =
                                                    p.Scp_Pens_Tp
                                                AND p.Scp_Psn IN ('0', '6')
                                                AND p.Scp_Pens_Tp IN ('2',
                                                                      '7',
                                                                      '9',
                                                                      '11')
                                                AND COALESCE (p.Scp_Begin_Dt,
                                                              SYSDATE) <=
                                                    SYSDATE
                                                AND COALESCE (p.Scp_End_Dt,
                                                              SYSDATE) >=
                                                    SYSDATE) Tp
                           ON     Tp.Scp_Sc = f.Scf_Sc
                              AND COALESCE (Tp.Scp_End_Dt, SYSDATE) =
                                  COALESCE (d.Scy_Till_Dt, SYSDATE)
                              AND Tp.Pens_Tp_Name = d.Scy_Reason
                 WHERE f.Scf_Is_Dasabled = 'T' AND Tp.Scp_Id IS NULL)
        LOOP
            Check_Jobs_Terminated;

            Lock_Disability (Rec1.Scf_Sc);

            --проставлення інвалідності
            Uss_Person.Api$socialcard.Save_Sc_Feature (
                p_Scf_Id            => Rec1.Scf_Id,
                p_Scf_Sc            => Rec1.Scf_Sc,
                p_Scf_Is_Dasabled   => 'F',
                p_New_Id            => Rec1.Scf_Id);

            --Переводимо поточний запис з інформацією про інвалідність в історичний статус
            UPDATE Sc_Disability d
               SET d.Scy_Stop_Dt = v_Curr_Dt, d.History_Status = 'H'
             WHERE d.Scy_Id = Rec1.Scy_Id;

            IF l_Iter >= 500
            THEN
                COMMIT;
                l_Iter := 0;
            END IF;

            l_Iter := l_Iter + 1;
        END LOOP;

        COMMIT;
        l_Iter := 0;

        --#79791 проставлення інвалідності на основі наявності пенсії по інвалідності
        FOR Rec2
            IN (SELECT Scp_Sc,
                       Scp_Begin_Dt,
                       Scp_End_Dt,
                       Scp_Tp_Name,
                       Scf_Id,
                       Scy_Id
                  FROM (SELECT p.Scp_Id,
                               p.Scp_Sc,
                               p.Scp_Begin_Dt,
                               p.Scp_End_Dt,
                               (SELECT Dic_Name
                                  FROM Uss_Ndi.v_Ddn_Scp_Pens_Tp
                                 WHERE Dic_Value = p.Scp_Pens_Tp)
                                   AS Scp_Tp_Name,
                               MAX (p.Scp_Id) OVER (PARTITION BY p.Scp_Sc)
                                   AS Max_Scp_Id,
                               f.Scf_Id,
                               d.Scy_Id
                          FROM Sc_Pension  p
                               LEFT JOIN Sc_Feature f ON f.Scf_Sc = p.Scp_Sc
                               LEFT JOIN Sc_Disability d
                                   ON     d.Scy_Sc = p.Scp_Sc
                                      AND d.History_Status = 'A'
                         WHERE     COALESCE (p.Scp_Psn, '0') IN ('0', '6')
                               AND p.Scp_Pens_Tp IN ('2',
                                                     '7',
                                                     '9',
                                                     '11')
                               AND COALESCE (p.Scp_Begin_Dt, SYSDATE) <=
                                   SYSDATE
                               AND COALESCE (p.Scp_End_Dt, SYSDATE) >=
                                   SYSDATE
                               AND COALESCE (f.Scf_Is_Dasabled, 'F') = 'F')
                 WHERE Scp_Id = Max_Scp_Id)
        LOOP
            Check_Jobs_Terminated;

            Lock_Disability (Rec2.Scp_Sc);

            --проставлення інвалідності
            Uss_Person.Api$socialcard.Save_Sc_Feature (
                p_Scf_Id            => Rec2.Scf_Id,
                p_Scf_Sc            => Rec2.Scp_Sc,
                p_Scf_Is_Dasabled   => 'T',
                p_New_Id            => Rec2.Scf_Id);

            --збереження інформації про інвалідність
            Api$socialcard.Save_Sc_Disability (
                p_Scy_Sc              => Rec2.Scp_Sc,
                p_Scy_Group           => NULL,
                p_Scy_Scd             => NULL,
                p_Scy_Inspection_Dt   => NULL,
                p_Scy_Decision_Dt     => NULL,
                p_Scy_Till_Dt         => Rec2.Scp_End_Dt,
                p_Scy_Reason          => Rec2.Scp_Tp_Name,
                p_Scy_Start_Dt        => v_Curr_Dt,
                p_Scy_Stop_Dt         => NULL,
                p_Scy_Dh              => NULL,
                p_History_Status      => 'A');

            --Переводимо поточний запис з інформацією про інвалідність в історичний статус
            IF Rec2.Scy_Id IS NOT NULL
            THEN
                UPDATE Sc_Disability d
                   SET d.Scy_Stop_Dt = v_Curr_Dt, d.History_Status = 'H'
                 WHERE d.Scy_Id = Rec2.Scy_Id;
            END IF;

            IF l_Iter >= 500
            THEN
                COMMIT;
                l_Iter := 0;
            END IF;

            l_Iter := l_Iter + 1;
        END LOOP;

        --так як виклик процедури відбувається в загальному пулі з перерахунком інших фіч - фіксуємо зміни
        COMMIT;
    END;

    --=============================================================
    --  Масовий перерахунок всіх ознак в соціальних картках
    --=============================================================
    PROCEDURE Recalc_Features
    IS
    BEGIN
        Check_Jobs_Terminated;
        Recalc_Disability_Features;
        Recalc_Common_Features;
    END;

    --------------------------------------------------------
    --  Встановлення ознаки про смерть
    --------------------------------------------------------
    PROCEDURE Set_Sc_Death (p_Sc_Id      IN NUMBER,
                            p_Scd_Id     IN NUMBER,
                            p_Death_Dt   IN DATE,
                            p_Note       IN VARCHAR2,
                            p_Src        IN VARCHAR2,
                            p_Src_Dt     IN DATE)
    IS
        l_Scf_Id   NUMBER;
        l_Scc      Sc_Change%ROWTYPE;
        l_Sch_Id   NUMBER;
    BEGIN
        --Отримуємо поточний зріз соцкартки
        SELECT Cc.*
          INTO l_Scc
          FROM Socialcard c JOIN Sc_Change Cc ON c.Sc_Scc = Cc.Scc_Id
         WHERE c.Sc_Id = p_Sc_Id;

        SELECT MAX (d.Sch_Id)
          INTO l_Sch_Id
          FROM Sc_Death d
         WHERE     d.Sch_Sc = p_Sc_Id
               AND d.Sch_Scd = p_Scd_Id
               AND d.Sch_Src = p_Src
               AND d.Sch_Dt = p_Death_Dt
               AND NVL (d.Sch_Note, '-') = NVL (p_Note, '-')
               AND d.Sch_Is_Dead = 'T';

        IF l_Sch_Id IS NULL
        THEN
            --Зберігаємо інформацію про смерть
            Api$socialcard.Save_Sc_Death (p_Sch_Id        => NULL,
                                          p_Sch_Scd       => p_Scd_Id,
                                          p_Sch_Dt        => p_Death_Dt,
                                          p_Sch_Note      => p_Note,
                                          p_Sch_Src       => p_Src,
                                          p_Sch_Sc        => p_Sc_Id,
                                          p_Sch_Is_Dead   => 'T',
                                          p_New_Id        => l_Sch_Id);
        END IF;

        IF l_Sch_Id <> NVL (l_Scc.Scc_Sch, -1)
        THEN
            --Створюємо новий зріз соцкартки
            Api$socialcard.Save_Sc_Change (p_Scc_Id          => NULL,
                                           p_Scc_Sc          => p_Sc_Id,
                                           p_Scc_Create_Dt   => SYSDATE,
                                           p_Scc_Src         => p_Src,
                                           p_Scc_Sct         => l_Scc.Scc_Sct,
                                           p_Scc_Sci         => l_Scc.Scc_Sci,
                                           p_Scc_Scb         => l_Scc.Scc_Scb,
                                           p_Scc_Sca         => l_Scc.Scc_Sca,
                                           p_Scc_Sch         => l_Sch_Id,
                                           p_Scc_Scp         => l_Scc.Scc_Scp,
                                           p_Scc_Src_Dt      => p_Src_Dt,
                                           p_New_Id          => l_Scc.Scc_Id);
            --Записуємо посилання на новий зріз до соцкартки
            Api$socialcard.Set_Sc_Scc (p_Sc_Id    => p_Sc_Id,
                                       p_Sc_Scc   => l_Scc.Scc_Id);
        END IF;

        l_Scf_Id := Api$socialcard.Get_Sc_Scf (p_Sc_Id);
        --Зберігаємо ознаку про смерть
        Api$socialcard.Save_Sc_Feature (p_Scf_Id        => l_Scf_Id,
                                        p_Scf_Sc        => p_Sc_Id,
                                        p_Scf_Is_Dead   => 'T',
                                        p_New_Id        => l_Scf_Id);
    END;

    --------------------------------------------------------
    --  Зняття ознаки про смерть
    --------------------------------------------------------
    PROCEDURE Unset_Sc_Death (p_Sc_Id    IN NUMBER,
                              p_Scd_Id   IN NUMBER,
                              p_Src      IN VARCHAR2,
                              p_Src_Dt   IN DATE)
    IS
        l_Scc      Sc_Change%ROWTYPE;
        l_Scf_Id   NUMBER;
    BEGIN
        BEGIN
            --Перевіряємо чи посилається поточний зріз соцкартки на інформацію про смерть,
            --яку було встановлено згідно ваказаного документу
            SELECT Cc.*
              INTO l_Scc
              FROM Socialcard  c
                   JOIN Sc_Change Cc ON c.Sc_Scc = Cc.Scc_Id
                   JOIN Sc_Death d ON Cc.Scc_Sch = d.Sch_Id
             WHERE c.Sc_Id = p_Sc_Id AND d.Sch_Scd = p_Scd_Id;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                RETURN;
        END;

        --Створюємо новий зріз соцкартки
        Api$socialcard.Save_Sc_Change (p_Scc_Id          => NULL,
                                       p_Scc_Sc          => p_Sc_Id,
                                       p_Scc_Create_Dt   => SYSDATE,
                                       p_Scc_Src         => p_Src,
                                       p_Scc_Sct         => l_Scc.Scc_Sct,
                                       p_Scc_Sci         => l_Scc.Scc_Sci,
                                       p_Scc_Scb         => l_Scc.Scc_Scb,
                                       p_Scc_Sca         => l_Scc.Scc_Sca,
                                       p_Scc_Sch         => -1, --Прибираємо посилання на інформацію про смерть
                                       p_Scc_Scp         => l_Scc.Scc_Scp,
                                       p_Scc_Src_Dt      => p_Src_Dt,
                                       p_New_Id          => l_Scc.Scc_Id);

        --Записуємо посилання на новий зріз до соцкартки
        Api$socialcard.Set_Sc_Scc (p_Sc_Id    => p_Sc_Id,
                                   p_Sc_Scc   => l_Scc.Scc_Id);

        l_Scf_Id := Api$socialcard.Get_Sc_Scf (p_Sc_Id);
        --Знімаємо ознаку про смерть
        Api$socialcard.Save_Sc_Feature (p_Scf_Id        => l_Scf_Id,
                                        p_Scf_Sc        => p_Sc_Id,
                                        p_Scf_Is_Dead   => 'F',
                                        p_New_Id        => l_Scf_Id);
    END;
BEGIN
    Init_Ndt2feature;
END Api$feature;
/