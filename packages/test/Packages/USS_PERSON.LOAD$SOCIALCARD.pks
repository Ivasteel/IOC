/* Formatted on 8/12/2025 5:56:55 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_PERSON.LOAD$SOCIALCARD
IS
    -- Author  : JSHPAK
    -- Created : 14.12.2021 16:27:17
    -- Purpose :

    c_Mode_Search_Update_Create   CONSTANT NUMBER := 0; -- изначальный режим, поиск, нашли то актуализируем, ненашли то создаем и наполняем
    c_Mode_Search                 CONSTANT NUMBER := 1; -- первый дополнительный режим, только поиск
    c_Mode_Search_Update          CONSTANT NUMBER := 2; -- второй дополнительный режим, поиск при успешном нахождении актуализация, если не нашли то НЕ СОЗДАЕМ  новую персону
    c_Mode_Search_Create          CONSTANT NUMBER := 3; -- IC #101419 пошук, якщо не знайшли - створення

    g_Pib_Mismatch_On_Ipn                  BOOLEAN;
    g_Ipn_Invalid                          BOOLEAN;
    g_Is_New_Sc                            BOOLEAN; -- 14/06/2024 serhii: #95404 used in Dnet$exch_Uss2ikis.Handle_Put_Benefit_Cat_Req

    FUNCTION Get_Load_Sc_Ses (p_Fn         IN VARCHAR2,
                              p_Ln         IN VARCHAR2,
                              p_Mn         IN VARCHAR2,
                              p_Birth_Dt   IN DATE,
                              p_Inn_Num    IN VARCHAR2,
                              p_Inn_Ndt    IN NUMBER,
                              p_Doc_Ser    IN VARCHAR2,
                              p_Doc_Num    IN VARCHAR2,
                              p_Doc_Ndt    IN NUMBER,
                              p_Sc         IN NUMBER)
        RETURN NUMBER;

    FUNCTION Load_Sc (p_Fn                IN     VARCHAR2,
                      p_Ln                IN     VARCHAR2,
                      p_Mn                IN     VARCHAR2,
                      p_Gender            IN     VARCHAR,
                      p_Nationality       IN     VARCHAR2,
                      p_Src_Dt            IN     DATE,
                      p_Birth_Dt          IN     DATE,
                      p_Inn_Num           IN     VARCHAR2,
                      p_Inn_Ndt           IN     NUMBER,
                      p_Doc_Ser           IN     VARCHAR2,
                      p_Doc_Num           IN     VARCHAR2,
                      p_Doc_Ndt           IN     NUMBER,
                      p_Src               IN     VARCHAR2,
                      p_Sc                IN OUT Socialcard.Sc_Id%TYPE,
                      p_Sc_Unique         IN OUT Socialcard.Sc_Unique%TYPE,
                      p_Mode              IN     NUMBER DEFAULT 0,
                      p_Email             IN     VARCHAR2 DEFAULT NULL,
                      p_Is_Email_Inform   IN     VARCHAR2 DEFAULT NULL,
                      p_Phone             IN     VARCHAR2 DEFAULT NULL,
                      p_Is_Phone_Inform   IN     VARCHAR2 DEFAULT NULL)
        RETURN NUMBER;

    FUNCTION Search_By_Ipn (p_Ipn_Num     IN     VARCHAR2,
                            p_Ln          IN     VARCHAR2,
                            p_Fn          IN     VARCHAR2,
                            p_Mn          IN     VARCHAR2,
                            p_Sc_Unique      OUT VARCHAR2)
        RETURN NUMBER;

    FUNCTION Search_Unique_By_Sc (p_Sc             IN     NUMBER,
                                  p_Ln             IN     VARCHAR2 DEFAULT NULL,
                                  p_Fn             IN     VARCHAR2 DEFAULT NULL,
                                  p_Mn             IN     VARCHAR2 DEFAULT NULL,
                                  p_Is_Pib_Match      OUT NUMBER)
        RETURN VARCHAR2;

    FUNCTION Load_Sc_Intrnl (
        p_Fn                IN     VARCHAR2,
        p_Ln                IN     VARCHAR2,
        p_Mn                IN     VARCHAR2,
        p_Gender            IN     VARCHAR,
        p_Nationality       IN     VARCHAR2,
        p_Src_Dt            IN     DATE,
        p_Birth_Dt          IN     DATE,
        p_Inn_Num           IN     VARCHAR2,
        p_Inn_Ndt           IN     NUMBER,
        p_Doc_Ser           IN     VARCHAR2,
        p_Doc_Num           IN     VARCHAR2,
        p_Doc_Ndt           IN     NUMBER,
        p_Doc_Unzr          IN     VARCHAR2 DEFAULT NULL,
        p_Doc_Is            IN     VARCHAR2 DEFAULT NULL,
        p_Doc_Bdt           IN     DATE DEFAULT NULL,
        p_Doc_Edt           IN     DATE DEFAULT NULL,
        p_Src               IN     VARCHAR2,
        p_Sc                IN OUT Socialcard.Sc_Id%TYPE,
        p_Sc_Unique         IN OUT Socialcard.Sc_Unique%TYPE,
        p_Sc_Scc               OUT Socialcard.Sc_Scc%TYPE,
        p_Mode              IN     NUMBER DEFAULT 0,
        p_Note              IN     VARCHAR2 DEFAULT NULL,
        p_Email             IN     VARCHAR2 DEFAULT NULL,
        p_Is_Email_Inform   IN     VARCHAR2 DEFAULT NULL,
        p_Phone             IN     VARCHAR2 DEFAULT NULL,
        p_Is_Phone_Inform   IN     VARCHAR2 DEFAULT NULL)
        RETURN NUMBER;
END;
/


GRANT EXECUTE ON USS_PERSON.LOAD$SOCIALCARD TO II01RC_USS_PERSON_INT
/

GRANT EXECUTE ON USS_PERSON.LOAD$SOCIALCARD TO II01RC_USS_PERSON_RBM
/

GRANT EXECUTE ON USS_PERSON.LOAD$SOCIALCARD TO IKIS_RBM
/

GRANT EXECUTE ON USS_PERSON.LOAD$SOCIALCARD TO USS_ESR
/

GRANT EXECUTE ON USS_PERSON.LOAD$SOCIALCARD TO USS_EXCH
/

GRANT EXECUTE ON USS_PERSON.LOAD$SOCIALCARD TO USS_RNSP
/

GRANT EXECUTE ON USS_PERSON.LOAD$SOCIALCARD TO USS_RPT
/

GRANT EXECUTE ON USS_PERSON.LOAD$SOCIALCARD TO USS_VISIT
/


/* Formatted on 8/12/2025 5:57:04 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_PERSON.LOAD$SOCIALCARD
IS
    gLogSes   NUMBER;


    FUNCTION Get_Load_Sc_Ses (p_Fn         IN VARCHAR2,
                              p_Ln         IN VARCHAR2,
                              p_Mn         IN VARCHAR2,
                              p_Birth_Dt   IN DATE,
                              p_Inn_Num    IN VARCHAR2,
                              p_Inn_Ndt    IN NUMBER,
                              p_Doc_Ser    IN VARCHAR2,
                              p_Doc_Num    IN VARCHAR2,
                              p_Doc_Ndt    IN NUMBER,
                              p_Sc         IN NUMBER)
        RETURN NUMBER
    IS
        l_ses_id   NUMBER;
    BEGIN
        SELECT   -1
               * ORA_HASH (
                        p_Fn
                     || p_Ln
                     || p_Mn
                     || p_Inn_Num
                     || p_Inn_Ndt
                     || TO_CHAR (p_Birth_Dt, 'DD.MM.YYYY')
                     || p_Doc_Ser
                     || p_Doc_Num
                     || p_Doc_Ndt)
          INTO l_ses_id
          FROM DUAL;

        RETURN NVL (NVL (p_Sc, l_ses_id),
                    -1 * ROUND (DBMS_RANDOM.VALUE () * 1000000));
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN NVL (p_Sc, -1 * ROUND (DBMS_RANDOM.VALUE () * 1000000));
    END;

    -------------------------------------------------------------------------------
    --     Пошук/оновлення/створення соцкартки
    --    (операція залежить від режиму p_Mode)
    -------------------------------------------------------------------------------
    FUNCTION Load_Sc (p_Fn                IN     VARCHAR2,
                      p_Ln                IN     VARCHAR2,
                      p_Mn                IN     VARCHAR2,
                      p_Gender            IN     VARCHAR,
                      p_Nationality       IN     VARCHAR2,
                      p_Src_Dt            IN     DATE,
                      p_Birth_Dt          IN     DATE,
                      p_Inn_Num           IN     VARCHAR2,
                      p_Inn_Ndt           IN     NUMBER,
                      p_Doc_Ser           IN     VARCHAR2,
                      p_Doc_Num           IN     VARCHAR2,
                      p_Doc_Ndt           IN     NUMBER,
                      p_Src               IN     VARCHAR2,
                      p_Sc                IN OUT Socialcard.Sc_Id%TYPE,
                      p_Sc_Unique         IN OUT Socialcard.Sc_Unique%TYPE,
                      p_Mode              IN     NUMBER DEFAULT 0,
                      p_Email             IN     VARCHAR2 DEFAULT NULL,
                      p_Is_Email_Inform   IN     VARCHAR2 DEFAULT NULL,
                      p_Phone             IN     VARCHAR2 DEFAULT NULL,
                      p_Is_Phone_Inform   IN     VARCHAR2 DEFAULT NULL)
        RETURN NUMBER
    IS
        l_Sc       Socialcard.Sc_Id%TYPE;
        l_Sc_Scc   Socialcard.Sc_Scc%TYPE;
    BEGIN
        gLogSes :=
            Get_Load_Sc_Ses (p_Fn,
                             p_Ln,
                             p_Mn,
                             p_Birth_Dt,
                             p_Inn_Num,
                             p_Inn_Ndt,
                             p_Doc_Ser,
                             p_Doc_Num,
                             p_Doc_Ndt,
                             p_Sc);
        l_Sc :=
            Load_Sc_Intrnl (p_Fn                => p_Fn,
                            p_Ln                => p_Ln,
                            p_Mn                => p_Mn,
                            p_Gender            => p_Gender,
                            p_Nationality       => p_Nationality,
                            p_Src_Dt            => p_Src_Dt,
                            p_Birth_Dt          => p_Birth_Dt,
                            p_Inn_Num           => p_Inn_Num,
                            p_Inn_Ndt           => p_Inn_Ndt,
                            p_Doc_Ser           => p_Doc_Ser,
                            p_Doc_Num           => p_Doc_Num,
                            p_Doc_Ndt           => p_Doc_Ndt,
                            p_Src               => p_Src,
                            p_Sc                => p_Sc,
                            p_Sc_Unique         => p_Sc_Unique,
                            p_Sc_Scc            => l_Sc_Scc,
                            p_Mode              => p_Mode,  -- 0 - изначальный
                            p_Email             => p_Email,
                            p_Is_Email_Inform   => p_Is_Email_Inform,
                            p_Phone             => p_Phone,
                            p_Is_Phone_Inform   => p_Is_Phone_Inform);
        RETURN l_Sc;
    END;

    FUNCTION Validate_Ipn (p_Ipn         IN VARCHAR2,
                           p_Birthdate   IN DATE DEFAULT NULL,
                           p_Gender      IN VARCHAR2 DEFAULT NULL)
        RETURN BOOLEAN
    IS
        l_Is_Valid   NUMBER;
    BEGIN
        WITH
            i
            AS
                (SELECT NULLIF (LPAD (p_Ipn, 10, '-'), '0000000000')    AS Ipn
                   FROM DUAL),
            t
            AS
                (SELECT Ipn,
                        SUBSTR (Ipn, 1, 1)                      AS S1,
                        SUBSTR (Ipn, 2, 1)                      AS S2,
                        SUBSTR (Ipn, 3, 1)                      AS S3,
                        SUBSTR (Ipn, 4, 1)                      AS S4,
                        SUBSTR (Ipn, 5, 1)                      AS S5,
                        SUBSTR (Ipn, 6, 1)                      AS S6,
                        SUBSTR (Ipn, 7, 1)                      AS S7,
                        SUBSTR (Ipn, 8, 1)                      AS S8,
                        SUBSTR (Ipn, 9, 1)                      AS S9,
                        SUBSTR (Ipn, 10, 1)                     AS S10,
                        DECODE (p_Gender,  'M', 1,  'F', 0)     AS Gender
                   FROM i)
        SELECT CASE
                   WHEN     --Перевірка контрольної суми
                            MOD (
                                MOD (
                                      S1 * (-1)
                                    + S2 * 5
                                    + S3 * 7
                                    + S4 * 9
                                    + S5 * 4
                                    + S6 * 6
                                    + S7 * 10
                                    + S8 * 5
                                    + S9 * 7,
                                    11),
                                10) =
                            S10
                        AND (   --Для ІПН що починаюється з 8 не перевіряємо ДН та стать
                                (S1 = '8')
                             OR (    --Перірка за ДН
                                     (   --Якщо вказано ДН
                                         (    p_Birthdate IS NOT NULL
                                          AND   TO_DATE ('31.12.1899',
                                                         'dd.mm.yyyy')
                                              + TO_NUMBER (
                                                    SUBSTR (Ipn, 1, 5)) =
                                              p_Birthdate)
                                      --Якщо НЕ вказано ДН
                                      OR (    p_Birthdate IS NULL
                                          AND   TO_DATE ('31.12.1899',
                                                         'dd.mm.yyyy')
                                              + TO_NUMBER (
                                                    SUBSTR (Ipn, 1, 5)) <
                                              SYSDATE)--
                                                      )
                                 --Перевірка по статі
                                 AND (   Gender IS NULL
                                      OR (    Gender IN (1, 0)
                                          AND Gender =
                                              MOD (
                                                  TO_NUMBER (
                                                      SUBSTR (Ipn, 9, 1)),
                                                  2)))--
                                                      )--
                                                       )
                   THEN
                       1
                   ELSE
                       0
               END
          INTO l_Is_Valid
          FROM t
         WHERE t.Ipn IS NOT NULL;

        RETURN l_Is_Valid = 1;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN FALSE;
    END;

    -------------------------------------------------------------------------------
    --                      Пошук соцкартки за ІПН
    -------------------------------------------------------------------------------
    FUNCTION Search_By_Ipn (p_Ipn_Num     IN     VARCHAR2,
                            p_Ln          IN     VARCHAR2,
                            p_Fn          IN     VARCHAR2,
                            p_Mn          IN     VARCHAR2,
                            p_Sc_Unique      OUT VARCHAR2)
        RETURN NUMBER
    IS
        l_Sc          NUMBER;
        l_Pib_Match   NUMBER;
    BEGIN
          SELECT Scd_Sc, Sc_Unique, Pib_Match
            INTO l_Sc, p_Sc_Unique, l_Pib_Match
            FROM (SELECT --+ index(ddd) index(sc) use_nl(ddd sc)
                         Ddd.Scd_Sc,
                         Sc.Sc_Unique,
                         CASE
                             --Співпадіння імені та прізвища #94508
                             WHEN (   UTL_MATCH.Edit_Distance_Similarity (
                                          i.Sci_Fn || ' ' || i.Sci_Ln,
                                          p_Fn || ' ' || p_Ln) >=
                                        100
                                      * (    LENGTH (
                                                    i.Sci_Fn
                                                 || ' '
                                                 || i.Sci_Ln
                                                 || p_Fn
                                                 || ' '
                                                 || p_Ln)
                                           / 2
                                         - 2)
                                      /        -- (-2 = отличие в два символа)
                                        (  LENGTH (
                                                  i.Sci_Fn
                                               || ' '
                                               || i.Sci_Ln
                                               || p_Fn
                                               || ' '
                                               || p_Ln)
                                         / 2)
                                   OR --або співпадіння іменті та побатькові
                                      UTL_MATCH.Edit_Distance_Similarity (
                                          i.Sci_Fn || ' ' || i.Sci_Mn,
                                          p_Fn || ' ' || p_Mn) >=
                                        100
                                      * (    LENGTH (
                                                    i.Sci_Fn
                                                 || ' '
                                                 || i.Sci_Mn
                                                 || p_Fn
                                                 || ' '
                                                 || p_Mn)
                                           / 2
                                         - 2)
                                      /        -- (-2 = отличие в два символа)
                                        (  LENGTH (
                                                  i.Sci_Fn
                                               || ' '
                                               || i.Sci_Mn
                                               || p_Fn
                                               || ' '
                                               || p_Mn)
                                         / 2))
                             THEN
                                 1
                             ELSE
                                 0
                         END    AS Pib_Match
                    FROM Sc_Document Ddd
                         JOIN Socialcard Sc
                             ON     Sc.Sc_Id = Ddd.Scd_Sc
                                AND Sc.Sc_St IN ('1', '4')
                         JOIN Sc_Change Scc ON Sc.Sc_Scc = Scc.Scc_Id
                         JOIN Sc_Identity i ON Scc.Scc_Sci = i.Sci_Id
                   WHERE     Ddd.Scd_Number = NULLIF (p_Ipn_Num, '0000000000')
                         AND Ddd.Scd_St IN ('1'                       /*,'2'*/
                                               ) --# 86550 - вероятно, надеются, что тут случится магия и поток какашек станет меньше
                         AND Ddd.Scd_Ndt IN (5, 10366)) Ddd
        ORDER BY Pib_Match DESC,
                 CASE WHEN Sc_Unique NOT LIKE 'T%' THEN 0 ELSE 1 END ASC
           FETCH FIRST ROW ONLY;

        --#94508
        IF l_Pib_Match <> 1
        THEN
            l_Sc := NULL;
            p_Sc_Unique := NULL;
            g_Pib_Mismatch_On_Ipn := TRUE;
        END IF;

        RETURN l_Sc;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            RETURN NULL;
        WHEN OTHERS
        THEN
            RETURN 0;
    -- raise;
    END;

    -------------------------------------------------------------------------------
    --                      Отрімання соцкартки за ІД
    -------------------------------------------------------------------------------
    FUNCTION Search_Unique_By_Sc (p_Sc             IN     NUMBER,
                                  p_Ln             IN     VARCHAR2 DEFAULT NULL,
                                  p_Fn             IN     VARCHAR2 DEFAULT NULL,
                                  p_Mn             IN     VARCHAR2 DEFAULT NULL,
                                  p_Is_Pib_Match      OUT NUMBER)
        RETURN VARCHAR2
    IS
        l_Sc_Unique   VARCHAR2 (500);
    BEGIN
          SELECT Sc_Unique, Pib_Match
            INTO l_Sc_Unique, p_Is_Pib_Match
            FROM (SELECT --+ index(ddd) index(sc) use_nl(ddd sc)
                         Ddd.Scd_Sc,
                         Sc.Sc_Unique,
                         CASE
                             --Співпадіння імені та прізвища #94508
                             WHEN (   UTL_MATCH.Edit_Distance_Similarity (
                                          i.Sci_Fn || ' ' || i.Sci_Ln,
                                          p_Fn || ' ' || p_Ln) >=
                                        100
                                      * (    LENGTH (
                                                    i.Sci_Fn
                                                 || ' '
                                                 || i.Sci_Ln
                                                 || p_Fn
                                                 || ' '
                                                 || p_Ln)
                                           / 2
                                         - 2)
                                      /        -- (-2 = отличие в два символа)
                                        (  LENGTH (
                                                  i.Sci_Fn
                                               || ' '
                                               || i.Sci_Ln
                                               || p_Fn
                                               || ' '
                                               || p_Ln)
                                         / 2)
                                   OR --або співпадіння іменті та побатькові
                                      UTL_MATCH.Edit_Distance_Similarity (
                                          i.Sci_Fn || ' ' || i.Sci_Mn,
                                          p_Fn || ' ' || p_Mn) >=
                                        100
                                      * (    LENGTH (
                                                    i.Sci_Fn
                                                 || ' '
                                                 || i.Sci_Mn
                                                 || p_Fn
                                                 || ' '
                                                 || p_Mn)
                                           / 2
                                         - 2)
                                      /        -- (-2 = отличие в два символа)
                                        (  LENGTH (
                                                  i.Sci_Fn
                                               || ' '
                                               || i.Sci_Mn
                                               || p_Fn
                                               || ' '
                                               || p_Mn)
                                         / 2))
                             THEN
                                 1
                             ELSE
                                 0
                         END    AS Pib_Match
                    FROM Sc_Document Ddd
                         JOIN Socialcard Sc
                             ON     Sc.Sc_Id = Ddd.Scd_Sc
                                AND Sc.Sc_St IN ('1', '4')
                         JOIN Sc_Change Scc ON Sc.Sc_Scc = Scc.Scc_Id
                         JOIN Sc_Identity i ON Scc.Scc_Sci = i.Sci_Id
                   WHERE Ddd.Scd_Sc = p_Sc AND Ddd.Scd_St IN ('1'     /*,'2'*/
                                                                 ) --# 86550 - вероятно, надеются, что тут случится магия и поток какашек станет меньше
                                                                  ) Ddd
        ORDER BY Pib_Match DESC,
                 CASE WHEN Sc_Unique NOT LIKE 'T%' THEN 0 ELSE 1 END ASC
           FETCH FIRST ROW ONLY;


        RETURN l_Sc_Unique;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            RETURN NULL;
        WHEN OTHERS
        THEN
            RETURN 0;
    -- raise;
    END;


    -------------------------------------------------------------------------------
    --           Пошук соцкартки за документом що посвідчує особу та ПІБ
    -------------------------------------------------------------------------------
    FUNCTION Search_By_Doc_And_Fullname (p_Doc_Ndt     IN     NUMBER,
                                         p_Doc_Ser     IN     VARCHAR2,
                                         p_Doc_Num     IN     VARCHAR2,
                                         p_Ln          IN     VARCHAR2,
                                         p_Fn          IN     VARCHAR2,
                                         p_Mn          IN     VARCHAR2,
                                         p_Sc_Unique      OUT VARCHAR2,
                                         p_Sc_Scc         OUT NUMBER)
        RETURN NUMBER
    IS
        l_Sc   NUMBER;
    BEGIN
          /*
          create index I_SCD_SET4 on SC_DOCUMENT
          (UPPER(REPLACE(REPLACE(translate(SCD_SERIA||SCD_NUMBER,'1І','II'),'-',''),' ','')), SCD_NDT, SCD_ST)
          tablespace USS_PERSON_IND_TBS;
          */
          SELECT Scd_Sc, Sc_Unique, Sc_Scc
            INTO l_Sc, p_Sc_Unique, p_Sc_Scc
            FROM (SELECT --+ index(ddd i_scd_set3) index(sc) use_nl(ddd sc) index(scc) use_nl(sc scc) index(i) use_nl(scc i)
                         Ddd.Scd_Sc,
                         Sc.Sc_Unique,
                         Sc.Sc_Scc,
                         Ddd.Scd_Ndt,
                         Tt.Ndt_Order,
                         Ddd.Scd_St,
                         Sc.Sc_Id
                    FROM Sc_Document Ddd
                         JOIN Socialcard Sc
                             ON     Sc.Sc_Id = Ddd.Scd_Sc
                                AND Sc.Sc_St IN ('1', '4')
                         JOIN Sc_Change Scc ON Scc.Scc_Id = Sc.Sc_Scc
                         JOIN Sc_Identity i ON i.Sci_Id = Scc.Scc_Sci
                         JOIN Uss_Ndi.v_Ndi_Document_Type Tt
                             ON Tt.Ndt_Id = Ddd.Scd_Ndt     -- выбор по классу
                         JOIN Uss_Ndi.v_Ndi_Document_Type Tc
                             ON     Tc.Ndt_Ndc = Tt.Ndt_Ndc -- в рамках однотипной группы если указана или самого себя
                                AND COALESCE (Tc.Ndt_Uniq_Group,
                                              TO_CHAR (Tc.Ndt_Id)) =
                                    COALESCE (Tt.Ndt_Uniq_Group,
                                              TO_CHAR (Tt.Ndt_Id))
                   WHERE     (    UPPER (
                                      REPLACE (
                                          REPLACE (
                                              Ddd.Scd_Seria || Ddd.Scd_Number,
                                              '-',
                                              ''),
                                          ' ',
                                          '')) =
                                  UPPER (
                                      REPLACE (
                                          REPLACE (p_Doc_Ser || p_Doc_Num,
                                                   '-',
                                                   ''),
                                          ' ',
                                          ''))
                              AND p_Doc_Ndt <> 37)
                         AND Tc.Ndt_Id = p_Doc_Ndt
                         AND Ddd.Scd_St IN ('1'                       /*,'2'*/
                                               ) --# 86550 - вероятно, надеются, что тут случится магия и поток какашек станет меньше
                         AND UTL_MATCH.Edit_Distance_Similarity (
                                 i.Sci_Ln || ' ' || i.Sci_Fn || ' ' || i.Sci_Mn,
                                 p_Ln || ' ' || p_Fn || ' ' || p_Mn) >=
                               100
                             * (    LENGTH (
                                           i.Sci_Ln
                                        || ' '
                                        || i.Sci_Fn
                                        || ' '
                                        || i.Sci_Mn
                                        || p_Ln
                                        || ' '
                                        || p_Fn
                                        || ' '
                                        || p_Mn)
                                  / 2
                                - 2)
                             /                 -- (-2 = отличие в два символа)
                               (  LENGTH (
                                         i.Sci_Ln
                                      || ' '
                                      || i.Sci_Fn
                                      || ' '
                                      || i.Sci_Mn
                                      || p_Ln
                                      || ' '
                                      || p_Fn
                                      || ' '
                                      || p_Mn)
                                / 2)
                  UNION ALL
                  SELECT --+ index(ddd i_scd_set4) index(sc) use_nl(ddd sc) index(scc) use_nl(sc scc) index(i) use_nl(scc i)
                         Ddd.Scd_Sc,
                         Sc.Sc_Unique,
                         Sc.Sc_Scc,
                         Ddd.Scd_Ndt,
                         Tt.Ndt_Order,
                         Ddd.Scd_St,
                         Sc.Sc_Id
                    FROM Sc_Document Ddd
                         JOIN Socialcard Sc
                             ON     Sc.Sc_Id = Ddd.Scd_Sc
                                AND Sc.Sc_St IN ('1', '4')
                         JOIN Sc_Change Scc ON Scc.Scc_Id = Sc.Sc_Scc
                         JOIN Sc_Identity i ON i.Sci_Id = Scc.Scc_Sci
                         JOIN Uss_Ndi.v_Ndi_Document_Type Tt
                             ON Tt.Ndt_Id = Ddd.Scd_Ndt     -- выбор по классу
                         JOIN Uss_Ndi.v_Ndi_Document_Type Tc
                             ON     Tc.Ndt_Ndc = Tt.Ndt_Ndc -- в рамках однотипной группы если указана или самого себя
                                AND COALESCE (Tc.Ndt_Uniq_Group,
                                              TO_CHAR (Tc.Ndt_Id)) =
                                    COALESCE (Tt.Ndt_Uniq_Group,
                                              TO_CHAR (Tt.Ndt_Id))
                   WHERE     (    REPLACE (
                                      REPLACE (
                                          TRANSLATE (
                                              UPPER (
                                                     Ddd.Scd_Seria
                                                  || Ddd.Scd_Number),
                                              '1І',
                                              'II'),
                                          '-',
                                          ''),
                                      ' ',
                                      '') =
                                  REPLACE (
                                      REPLACE (
                                          TRANSLATE (
                                              UPPER (p_Doc_Ser || p_Doc_Num),
                                              '1І',
                                              'II'),
                                          '-',
                                          ''),
                                      ' ',
                                      '')
                              AND p_Doc_Ndt = 37)
                         AND Tc.Ndt_Id = p_Doc_Ndt
                         AND Ddd.Scd_St IN ('1'                       /*,'2'*/
                                               ) --# 86550 - вероятно, надеются, что тут случится магия и поток какашек станет меньше
                         AND UTL_MATCH.Edit_Distance_Similarity (
                                 i.Sci_Ln || ' ' || i.Sci_Fn || ' ' || i.Sci_Mn,
                                 p_Ln || ' ' || p_Fn || ' ' || p_Mn) >=
                               100
                             * (    LENGTH (
                                           i.Sci_Ln
                                        || ' '
                                        || i.Sci_Fn
                                        || ' '
                                        || i.Sci_Mn
                                        || p_Ln
                                        || ' '
                                        || p_Fn
                                        || ' '
                                        || p_Mn)
                                  / 2
                                - 2)
                             /                 -- (-2 = отличие в два символа)
                               (  LENGTH (
                                         i.Sci_Ln
                                      || ' '
                                      || i.Sci_Fn
                                      || ' '
                                      || i.Sci_Mn
                                      || p_Ln
                                      || ' '
                                      || p_Fn
                                      || ' '
                                      || p_Mn)
                                / 2)) Ddd
        ORDER BY  -- если тип документа поискового совпадает с типом найденого
                 CASE WHEN Scd_Ndt = 6 THEN 0 ELSE 1 END,
                 -- по приоритету в рамках класса
                 Ndt_Order,
                 -- постаянные КСС в приоритете перед временными
                 CASE WHEN Sc_Unique NOT LIKE 'T%' THEN 0 ELSE 1 END,
                 -- актуальные в приоритете перед неактуальными
                 Scd_St,
                 Sc_Id
           FETCH FIRST ROWS ONLY;

        RETURN l_Sc;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            RETURN NULL;
        WHEN OTHERS
        THEN
            RETURN 0;
    END;

    -------------------------------------------------------------------------------
    --     Пошук соцкартки за документом що посвідчує особу + ІБ + ДН
    -------------------------------------------------------------------------------
    FUNCTION Search_By_Doc_And_Partname_And_Birth (
        p_Doc_Ndt     IN     NUMBER,
        p_Doc_Ser     IN     VARCHAR2,
        p_Doc_Num     IN     VARCHAR2,
        p_Fn          IN     VARCHAR2,
        p_Mn          IN     VARCHAR2,
        p_Birth_Dt    IN     DATE,
        p_Sc_Unique      OUT VARCHAR2,
        p_Sc_Scc         OUT NUMBER)
        RETURN NUMBER
    IS
        l_Sc   NUMBER;
    BEGIN
          /*
          create index I_SCD_SET4 on SC_DOCUMENT
          (UPPER(REPLACE(REPLACE(translate(SCD_SERIA||SCD_NUMBER,'1І','II'),'-',''),' ','')), SCD_NDT, SCD_ST)
          tablespace USS_PERSON_IND_TBS;
          */
          SELECT Scd_Sc, Sc_Unique, Sc_Scc
            INTO l_Sc, p_Sc_Unique, p_Sc_Scc
            FROM (SELECT --+ index(ddd i_scd_set3) index(sc) use_nl(ddd sc) index(scc) use_nl(sc scc) index(i) use_nl(scc i) index(b) use_nl(scc b)
                         Ddd.Scd_Sc,
                         Sc.Sc_Unique,
                         Sc.Sc_Scc,
                         Ddd.Scd_Ndt,
                         Tt.Ndt_Order,
                         Ddd.Scd_St,
                         Sc.Sc_Id
                    FROM Sc_Document Ddd
                         JOIN Socialcard Sc
                             ON     Sc.Sc_Id = Ddd.Scd_Sc
                                AND Sc.Sc_St IN ('1', '4')
                         JOIN Sc_Change Scc ON Scc.Scc_Id = Sc.Sc_Scc
                         JOIN Sc_Identity i ON i.Sci_Id = Scc.Scc_Sci
                         JOIN Sc_Birth b ON b.Scb_Id = Scc.Scc_Scb
                         JOIN Uss_Ndi.v_Ndi_Document_Type Tt
                             ON Tt.Ndt_Id = Ddd.Scd_Ndt     -- выбор по классу
                         JOIN Uss_Ndi.v_Ndi_Document_Type Tc
                             ON     Tc.Ndt_Ndc = Tt.Ndt_Ndc -- в рамках однотипной группы если указана или самого себя
                                AND COALESCE (Tc.Ndt_Uniq_Group,
                                              TO_CHAR (Tc.Ndt_Id)) =
                                    COALESCE (Tt.Ndt_Uniq_Group,
                                              TO_CHAR (Tt.Ndt_Id))
                   WHERE     (    UPPER (
                                      REPLACE (
                                          REPLACE (
                                              Ddd.Scd_Seria || Ddd.Scd_Number,
                                              '-',
                                              ''),
                                          ' ',
                                          '')) =
                                  UPPER (
                                      REPLACE (
                                          REPLACE (p_Doc_Ser || p_Doc_Num,
                                                   '-',
                                                   ''),
                                          ' ',
                                          ''))
                              AND p_Doc_Ndt <> 37)
                         AND Tc.Ndt_Id = p_Doc_Ndt
                         AND Ddd.Scd_St IN ('1'                       /*,'2'*/
                                               ) --# 86550 - вероятно, надеются, что тут случится магия и поток какашек станет меньше
                         AND UTL_MATCH.Edit_Distance_Similarity (
                                 i.Sci_Fn || ' ' || i.Sci_Mn,
                                 p_Fn || ' ' || p_Mn) >=
                               100
                             * (    LENGTH (
                                           i.Sci_Fn
                                        || ' '
                                        || i.Sci_Mn
                                        || p_Fn
                                        || ' '
                                        || p_Mn)
                                  / 2
                                - 2)
                             /                 -- (-2 = отличие в два символа)
                               (  LENGTH (
                                         i.Sci_Fn
                                      || ' '
                                      || i.Sci_Mn
                                      || p_Fn
                                      || ' '
                                      || p_Mn)
                                / 2)
                         AND b.Scb_Dt = p_Birth_Dt
                  UNION ALL
                  SELECT --+ index(ddd i_scd_set4) index(sc) use_nl(ddd sc) index(scc) use_nl(sc scc) index(i) use_nl(scc i) index(b) use_nl(scc b)
                         Ddd.Scd_Sc,
                         Sc.Sc_Unique,
                         Sc.Sc_Scc,
                         Ddd.Scd_Ndt,
                         Tt.Ndt_Order,
                         Ddd.Scd_St,
                         Sc.Sc_Id
                    FROM Sc_Document Ddd
                         JOIN Socialcard Sc
                             ON     Sc.Sc_Id = Ddd.Scd_Sc
                                AND Sc.Sc_St IN ('1', '4')
                         JOIN Sc_Change Scc ON Scc.Scc_Id = Sc.Sc_Scc
                         JOIN Sc_Identity i ON i.Sci_Id = Scc.Scc_Sci
                         JOIN Sc_Birth b ON b.Scb_Id = Scc.Scc_Scb
                         JOIN Uss_Ndi.v_Ndi_Document_Type Tt
                             ON Tt.Ndt_Id = Ddd.Scd_Ndt     -- выбор по классу
                         JOIN Uss_Ndi.v_Ndi_Document_Type Tc
                             ON     Tc.Ndt_Ndc = Tt.Ndt_Ndc -- в рамках однотипной группы если указана или самого себя
                                AND COALESCE (Tc.Ndt_Uniq_Group,
                                              TO_CHAR (Tc.Ndt_Id)) =
                                    COALESCE (Tt.Ndt_Uniq_Group,
                                              TO_CHAR (Tt.Ndt_Id))
                   WHERE     (    REPLACE (
                                      REPLACE (
                                          TRANSLATE (
                                              UPPER (
                                                     Ddd.Scd_Seria
                                                  || Ddd.Scd_Number),
                                              '1І',
                                              'II'),
                                          '-',
                                          ''),
                                      ' ',
                                      '') =
                                  REPLACE (
                                      REPLACE (
                                          TRANSLATE (
                                              UPPER (p_Doc_Ser || p_Doc_Num),
                                              '1І',
                                              'II'),
                                          '-',
                                          ''),
                                      ' ',
                                      '')
                              AND p_Doc_Ndt = 37)
                         AND Tc.Ndt_Id = p_Doc_Ndt
                         AND Ddd.Scd_St IN ('1'                       /*,'2'*/
                                               ) --# 86550 - вероятно, надеются, что тут случится магия и поток какашек станет меньше
                         AND UTL_MATCH.Edit_Distance_Similarity (
                                 i.Sci_Fn || ' ' || i.Sci_Mn,
                                 p_Fn || ' ' || p_Mn) >=
                               100
                             * (    LENGTH (
                                           i.Sci_Fn
                                        || ' '
                                        || i.Sci_Mn
                                        || p_Fn
                                        || ' '
                                        || p_Mn)
                                  / 2
                                - 2)
                             /                 -- (-2 = отличие в два символа)
                               (  LENGTH (
                                         i.Sci_Fn
                                      || ' '
                                      || i.Sci_Mn
                                      || p_Fn
                                      || ' '
                                      || p_Mn)
                                / 2)
                         AND b.Scb_Dt = p_Birth_Dt) Ddd
        ORDER BY CASE WHEN Scd_Ndt = 6 THEN 0 ELSE 1 END,
                 -- если тип документа поискового совпадает с типом найденого
                 Ndt_Order,
                 -- по приоритету в рамках класса
                 CASE WHEN Sc_Unique NOT LIKE 'T%' THEN 0 ELSE 1 END,
                 -- постаянные КСС в приоритете перед временными
                 Scd_St,
                 -- актуальные в приоритете перед неактуальными
                 Sc_Id
           FETCH FIRST ROWS ONLY;

        RETURN l_Sc;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            RETURN NULL;
        WHEN OTHERS
        THEN
            RETURN 0;
    END;

    -------------------------------------------------------------------------------
    --                     Пошук соцкартки
    -------------------------------------------------------------------------------
    FUNCTION Search_Sc (p_Ipn_Num     IN     VARCHAR2,
                        p_Doc_Ndt     IN     NUMBER,
                        p_Doc_Ser     IN     VARCHAR2,
                        p_Doc_Num     IN     VARCHAR2,
                        p_Ln          IN     VARCHAR2,
                        p_Fn          IN     VARCHAR2,
                        p_Mn          IN     VARCHAR2,
                        p_Birth_Dt    IN     DATE,
                        p_Sc_Unique      OUT VARCHAR2,
                        p_Sc_Scc         OUT NUMBER)
        RETURN NUMBER
    IS
        l_Sc   NUMBER;
    BEGIN
        IKIS_SYS.IKIS_PROCEDURE_LOG.LOG (
            UPPER ('USS_PERSON.Load$socialcard.Search_Sc'),
            'SC',
            gLogSes,
               'p_Ipn_Num='
            || p_Ipn_Num
            || ', p_Fn='
            || p_Fn
            || ', p_Ln='
            || p_Ln
            || ', p_Mn='
            || p_Mn
            || ', p_Doc_Ndt='
            || p_Doc_Ndt
            || ', p_Doc_Num='
            || p_Doc_Num
            || ', p_Birth_Dt='
            || p_Birth_Dt,
            NULL);

        IF p_Ipn_Num IS NOT NULL
        THEN
            --Пошук соцкартки за ІПН(97% осіб буде знайдено за ІПН)
            l_Sc :=
                Search_By_Ipn (p_Ipn_Num     => p_Ipn_Num,
                               p_Ln          => p_Ln,
                               p_Fn          => p_Fn,
                               p_Mn          => p_Mn,
                               p_Sc_Unique   => p_Sc_Unique);
        END IF;

        IKIS_SYS.IKIS_PROCEDURE_LOG.LOG (
            UPPER ('USS_PERSON.Load$socialcard.Search_Sc'),
            'SC',
            gLogSes,
            'After search by INN. l_Sc= ' || l_Sc,
            NULL);

        --Пошук соцкартки за документом що посвідчує особу та ПІБ
        IF     l_Sc IS NULL
           AND p_Doc_Ndt IS NOT NULL
           AND p_Doc_Num IS NOT NULL
           AND p_Ln IS NOT NULL
           AND p_Fn IS NOT NULL
           AND p_Mn IS NOT NULL
        THEN
            l_Sc :=
                Search_By_Doc_And_Fullname (p_Doc_Ndt     => p_Doc_Ndt,
                                            p_Doc_Ser     => p_Doc_Ser,
                                            p_Doc_Num     => p_Doc_Num,
                                            p_Ln          => p_Ln,
                                            p_Fn          => p_Fn,
                                            p_Mn          => p_Mn,
                                            p_Sc_Unique   => p_Sc_Unique,
                                            p_Sc_Scc      => p_Sc_Scc);
        END IF;

        IKIS_SYS.IKIS_PROCEDURE_LOG.LOG (
            UPPER ('USS_PERSON.Load$socialcard.Search_Sc'),
            'SC',
            gLogSes,
            'After search by doc and full name. l_Sc= ' || l_Sc,
            NULL);

        --Пошук соцкартки за документом що посвідчує особу + ІБ + ДН
        IF     l_Sc IS NULL
           AND p_Doc_Ndt IS NOT NULL
           AND p_Doc_Num IS NOT NULL
           AND p_Fn IS NOT NULL
           AND p_Mn IS NOT NULL
           AND p_Birth_Dt IS NOT NULL
        THEN
            l_Sc :=
                Search_By_Doc_And_Partname_And_Birth (
                    p_Doc_Ndt     => p_Doc_Ndt,
                    p_Doc_Ser     => p_Doc_Ser,
                    p_Doc_Num     => p_Doc_Num,
                    p_Fn          => p_Fn,
                    p_Mn          => p_Mn,
                    p_Birth_Dt    => p_Birth_Dt,
                    p_Sc_Unique   => p_Sc_Unique,
                    p_Sc_Scc      => p_Sc_Scc);
        END IF;

        IKIS_SYS.IKIS_PROCEDURE_LOG.LOG (
            UPPER ('USS_PERSON.Load$socialcard.Search_Sc'),
            'SC',
            gLogSes,
            'After search by doc and part name. l_Sc= ' || l_Sc,
            NULL);


        RETURN l_Sc;
    END;

    -------------------------------------------------------------------------------
    --                         Збереження ДН
    -------------------------------------------------------------------------------
    PROCEDURE Save_Sc_Birth (p_Sc         IN            NUMBER,
                             p_Birth_Dt   IN            DATE,
                             p_Src        IN            VARCHAR2,
                             p_Scc        IN OUT NOCOPY v_Sc_Change%ROWTYPE)
    IS
        r_Scb   v_Sc_Birth%ROWTYPE;
    BEGIN
        -- по анкете выбираем информацию по дате рождения
        SELECT Scb.*
          INTO r_Scb
          FROM v_Sc_Birth Scb
         WHERE Scb.Scb_Id = COALESCE (p_Scc.Scc_Scb, -1);

        -- если текущая дата рождения отличается от новой даты рождения из параметра
        IF COALESCE (r_Scb.Scb_Dt, TO_DATE ('01.01.1777', 'dd.mm.yyyy')) <>
           p_Birth_Dt
        THEN
            -- выбираем была ли у этого пользователя эта дата рождения ранее
            BEGIN
                SELECT Scb.Scb_Id
                  INTO r_Scb.Scb_Id
                  FROM v_Sc_Birth Scb
                 WHERE     Scb.Scb_Sc = p_Sc
                       AND Scb.Scb_Dt = p_Birth_Dt
                       AND ROWNUM = 1;
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    r_Scb.Scb_Id := NULL;
            END;

            -- если ранее не использовалась то инсертим
            IF r_Scb.Scb_Id IS NULL
            THEN
                INSERT INTO Sc_Birth (Scb_Id,
                                      Scb_Sc,
                                      Scb_Sca,
                                      Scb_Scd,
                                      Scb_Dt,
                                      Scb_Note,
                                      Scb_Src,
                                      Scb_Ln)
                     VALUES (NULL,
                             p_Sc,
                             -1,
                             -1,
                             p_Birth_Dt,
                             '',
                             p_Src,
                             -1)
                     RETURN Scb_Id
                       INTO r_Scb.Scb_Id;
            END IF;

            -- отмечаем что меняем анкету
            --#109620
            IF COALESCE (p_Scc.Scc_Scb, -1) <> r_Scb.Scb_Id
            THEN
                p_Scc.Scc_Id := NULL;
                p_Scc.Scc_Scb := r_Scb.Scb_Id;
            END IF;
        END IF;
    END;

    -------------------------------------------------------------------------------
    --           Збереження ПІБа, статі та громадянства
    -------------------------------------------------------------------------------
    PROCEDURE Save_Sc_Identity (
        p_Sc            IN            NUMBER,
        p_Ln            IN            VARCHAR2,
        p_Fn            IN            VARCHAR2,
        p_Mn            IN            VARCHAR2,
        p_Gender        IN            VARCHAR,
        p_Nationality   IN            VARCHAR2,
        p_Scc           IN OUT NOCOPY v_Sc_Change%ROWTYPE)
    IS
        r_Sci           v_Sc_Identity%ROWTYPE;
        l_Nationality   v_Sc_Identity.Sci_Nationality%TYPE := p_Nationality;
        l_Gender        v_Sc_Identity.Sci_Gender%TYPE := p_Gender;
    BEGIN
        IKIS_SYS.IKIS_PROCEDURE_LOG.LOG (
            UPPER ('USS_PERSON.Load$socialcard.Save_Sc_Identity'),
            'SC',
            gLogSes,
               'p_Sc='
            || p_Sc
            || ', p_Fn='
            || p_Fn
            || ', p_Ln='
            || p_Ln
            || ', p_Mn='
            || p_Mn,
            NULL);

        -- по анкете выбираем информацию по атрибутике персоны
        SELECT Sci.*
          INTO r_Sci
          FROM v_Sc_Identity Sci
         WHERE Sci.Sci_Id = COALESCE (p_Scc.Scc_Sci, -1);

        -- проверяем национальность/пол если пришло неизвестное значение
        IF (COALESCE (l_Nationality, '-1') = '-1')
        THEN
            l_Nationality := r_Sci.Sci_Nationality;
        END IF;

        IF (COALESCE (l_Gender, 'V') = 'V')
        THEN
            l_Gender := r_Sci.Sci_Gender;
        END IF;

        -- если старая инфа отличается от новой
        IF    COALESCE (r_Sci.Sci_Ln, '-1') <> COALESCE (p_Ln, '-1')
           OR COALESCE (r_Sci.Sci_Fn, '-1') <> COALESCE (p_Fn, '-1')
           OR COALESCE (r_Sci.Sci_Mn, '-1') <> COALESCE (p_Mn, '-1')
           OR COALESCE (r_Sci.Sci_Gender, 'V') <> COALESCE (l_Gender, 'V')
           OR COALESCE (r_Sci.Sci_Nationality, '-1') <>
              COALESCE (l_Nationality, '-1')
        THEN
            -- выбираем была ли у этого пользователя эта инфа по фио ранее
            BEGIN
                SELECT Sci.Sci_Id
                  INTO r_Sci.Sci_Id
                  FROM v_Sc_Identity Sci
                 WHERE     Sci.Sci_Sc = p_Sc
                       AND COALESCE (Sci.Sci_Ln, '-1') =
                           COALESCE (p_Ln, '-1')
                       AND COALESCE (Sci.Sci_Fn, '-1') =
                           COALESCE (p_Fn, '-1')
                       AND COALESCE (Sci.Sci_Mn, '-1') =
                           COALESCE (p_Mn, '-1')
                       AND COALESCE (Sci.Sci_Gender, 'V') =
                           COALESCE (l_Gender, 'V')
                       AND COALESCE (Sci.Sci_Nationality, '-1') =
                           COALESCE (l_Nationality, '-1')
                       AND ROWNUM = 1;
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    r_Sci.Sci_Id := NULL;
            END;

            IKIS_SYS.IKIS_PROCEDURE_LOG.LOG (
                UPPER ('USS_PERSON.Load$socialcard.Save_Sc_Identity'),
                'SC',
                gLogSes,
                'Before create idenity: r_Sci.Sci_Id=' || r_Sci.Sci_Id,
                NULL);

            -- если ранее не использовалась то инсертим
            IF r_Sci.Sci_Id IS NULL
            THEN
                INSERT INTO Sc_Identity (Sci_Id,
                                         Sci_Sc,
                                         Sci_Fn,
                                         Sci_Ln,
                                         Sci_Mn,
                                         Sci_Gender,
                                         Sci_Nationality)
                     VALUES (r_Sci.Sci_Id,
                             p_Sc,
                             p_Fn,
                             p_Ln,
                             p_Mn,
                             l_Gender,
                             l_Nationality)
                     RETURN Sci_Id
                       INTO r_Sci.Sci_Id;
            END IF;

            IKIS_SYS.IKIS_PROCEDURE_LOG.LOG (
                UPPER ('USS_PERSON.Load$socialcard.Save_Sc_Identity'),
                'SC',
                gLogSes,
                'After create idenity: new r_Sci.Sci_Id=' || r_Sci.Sci_Id,
                NULL);
            -- отмечаем что меняем анкету
            p_Scc.Scc_Id := NULL;
            p_Scc.Scc_Sci := r_Sci.Sci_Id;
        ELSE
            IKIS_SYS.IKIS_PROCEDURE_LOG.LOG (
                UPPER ('USS_PERSON.Load$socialcard.Save_Sc_Identity'),
                'SC',
                gLogSes,
                'Data is not changed',
                NULL);
        END IF;
    END;

    -------------------------------------------------------------------------------
    --           Збереження контактних даних
    -------------------------------------------------------------------------------
    PROCEDURE Save_Sc_Contacts (
        p_Sc                IN            NUMBER,
        p_Email             IN            VARCHAR2 DEFAULT NULL,
        p_Is_Email_Inform   IN            VARCHAR2 DEFAULT NULL,
        p_Scc               IN OUT NOCOPY v_Sc_Change%ROWTYPE)
    IS
        r_Sct   v_Sc_Contact%ROWTYPE;
    BEGIN
        -- по анкете выбираем информацию по атрибутике персоны
        SELECT Sct.*
          INTO r_Sct
          FROM v_Sc_Contact Sct
         WHERE Sct.Sct_Id = COALESCE (p_Scc.Scc_Sct, -1);

        -- если старая инфа отличается от новой
        IF (   (COALESCE (r_Sct.Sct_Email, '-1') <>
                COALESCE (p_Email, r_Sct.Sct_Email, '-1'))
            OR (    COALESCE (r_Sct.Sct_Email, '-1') =
                    COALESCE (p_Email, r_Sct.Sct_Email, '-1')
                AND COALESCE (r_Sct.Sct_Is_Email_Inform, '-1') <>
                    COALESCE (p_Is_Email_Inform, '-1')))
        THEN
            -- выбираем была ли у этого пользователя эта инфа по фио ранее
            BEGIN
                  SELECT Sct.Sct_Id
                    INTO r_Sct.Sct_Id
                    FROM v_Sc_Contact Sct
                         JOIN v_Sc_Change Scc ON Scc.Scc_Sct = Sct.Sct_Id
                   WHERE     Scc.Scc_Sc = p_Sc
                         AND COALESCE (Sct.Sct_Email, '-1') =
                             COALESCE (p_Email, r_Sct.Sct_Email, '-1')
                         AND COALESCE (Sct.Sct_Is_Email_Inform, '-1') =
                             COALESCE (p_Is_Email_Inform,
                                       r_Sct.Sct_Is_Email_Inform,
                                       '-1')
                ORDER BY CASE
                             WHEN Sct.Sct_Id = r_Sct.Sct_Id THEN 0
                             ELSE 1
                         END,
                         Sct.Sct_Id
                   FETCH FIRST ROWS ONLY;

                DBMS_OUTPUT.Put_Line (r_Sct.Sct_Id);
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    r_Sct.Sct_Id := NULL;
                    DBMS_OUTPUT.Put_Line (r_Sct.Sct_Id);
            END;

            -- если ранее не использовалась то инсертим
            IF r_Sct.Sct_Id IS NULL
            THEN
                INSERT INTO Sc_Contact (Sct_Id,
                                        Sct_Phone_Mob,
                                        Sct_Phone_Num,
                                        Sct_Fax_Num,
                                        Sct_Email,
                                        Sct_Note,
                                        Sct_Is_Mob_Inform,
                                        Sct_Is_Email_Inform)
                     VALUES (r_Sct.Sct_Id,
                             r_Sct.Sct_Phone_Mob,
                             r_Sct.Sct_Phone_Num,
                             r_Sct.Sct_Fax_Num,
                             COALESCE (p_Email, r_Sct.Sct_Email),
                             r_Sct.Sct_Note,
                             r_Sct.Sct_Is_Mob_Inform,
                             p_Is_Email_Inform)
                     RETURN Sct_Id
                       INTO r_Sct.Sct_Id;
            END IF;

            -- отмечаем что меняем анкету
            DBMS_OUTPUT.Put_Line (p_Scc.Scc_Sct || '-' || r_Sct.Sct_Id);

            IF p_Scc.Scc_Sct <> r_Sct.Sct_Id
            THEN
                p_Scc.Scc_Id := NULL;
                p_Scc.Scc_Sct := r_Sct.Sct_Id;
            END IF;
        END IF;
    END;

    -------------------------------------------------------------------------------
    --                  Збереження ІПН
    -------------------------------------------------------------------------------
    PROCEDURE Save_Ipn (p_Sc        IN NUMBER,
                        p_Inn_Ndt   IN NUMBER,
                        p_Inn_Num   IN VARCHAR2,
                        p_Last      IN NUMBER,
                        p_Src       IN VARCHAR2)
    IS
        r_Scd   v_Sc_Document%ROWTYPE;
        l_res   VARCHAR2 (500);

        PROCEDURE LOG (p_Action IN VARCHAR2, p_Clob IN CLOB DEFAULT NULL)
        IS
        BEGIN
            IKIS_SYS.IKIS_PROCEDURE_LOG.LOG (
                UPPER ('USS_PERSON.Load$socialcard.Save_Ipn'),
                'SC',
                gLogSes,
                p_Action,
                p_Clob);
        END;
    --#113333
    BEGIN
        LOG (
               'Start. p_Sc='
            || p_Sc
            || ', p_Inn_Ndt='
            || p_Inn_Ndt
            || ', p_Inn_Num='
            || p_Inn_Num
            || ', p_Last='
            || p_Last
            || ', p_Src='
            || p_Src);

        BEGIN
            SELECT MAX (d.scd_sc)
              INTO l_res
              FROM v_Sc_Document d
             WHERE     d.Scd_St IN ('1')
                   AND d.Scd_Ndt IN (5, 10366)
                   AND d.Scd_Number = p_Inn_Num
                   AND d.scd_sc <> p_Sc;

            IF l_res IS NOT NULL
            THEN
                LOG ('INN found on another SC. Another_Sc=' || l_res);
                RAISE_APPLICATION_ERROR (
                    -20000,
                       'ІПН ['
                    || p_Inn_Num
                    || '] знайдено в активних документах іншої СРКО ['
                    || l_res
                    || ']');
            END IF;

            --Знаходимо РНОКПП з тим самим значенням
            SELECT d.Scd_Id
              INTO r_Scd.Scd_Id
              FROM v_Sc_Document d
             WHERE     d.Scd_Sc = p_Sc
                   AND d.Scd_St IN ('1'                               /*,'2'*/
                                       ) --# 86550 - вероятно, надеются, что тут случится магия и поток какашек станет меньше
                   AND d.Scd_Ndt IN (5, 10366)
                   AND d.Scd_Number = p_Inn_Num;

            LOG ('Scd founded. r_Scd.Scd_Id=' || r_Scd.Scd_Id);

            -- предыдущий отличный актуальный перводим в неактуальный для последнего среза
            UPDATE v_Sc_Document Ddd
               SET Ddd.Scd_St = '2'
             WHERE     Ddd.Scd_Sc = p_Sc
                   AND Ddd.Scd_Ndt IN (5, 10366)
                   AND Ddd.Scd_St IN ('1')
                   AND p_Last = 1
                   AND Ddd.Scd_Id <> r_Scd.Scd_Id;

            LOG ('Updated rows for founded SCD ID amount = ' || SQL%ROWCOUNT);
        -- не нашли инн, упали в ошибку
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                -- сбрасываем инфу по анкете для образования среза (пересчет ИНФО)
                r_Scd.Scd_Id := NULL;
                LOG ('Scd not found.');
            WHEN TOO_MANY_ROWS
            THEN
                -- сбрасываем инфу по анкете для образования среза (пересчет ИНФО)
                r_Scd.Scd_Id := NULL;
                LOG ('Too many rows found.');
        END;

        -- если нет инн, создаем
        IF r_Scd.Scd_Id IS NULL
        THEN
            UPDATE v_Sc_Document Ddd
               SET Ddd.Scd_St = '2'
             WHERE     Ddd.Scd_Sc = p_Sc
                   AND Ddd.Scd_Ndt IN (5, 10366)
                   AND Ddd.Scd_St = '1'
                   AND p_Last = 1;

            LOG ('Updated rows for EMPTY SCD ID amount = ' || SQL%ROWCOUNT);

            -- вставка документов (ИНН)
            INSERT INTO Sc_Document (Scd_Id,
                                     Scd_Sc,
                                     Scd_Name,
                                     Scd_Seria,
                                     Scd_Number,
                                     Scd_Issued_Dt,
                                     Scd_Issued_Who,
                                     Scd_Start_Dt,
                                     Scd_Stop_Dt,
                                     Scd_St,
                                     Scd_Src,
                                     Scd_Note,
                                     Scd_Ndt,
                                     Scd_Doc,
                                     Scd_Dh)
                 VALUES (r_Scd.Scd_Id,
                         p_Sc,
                         NULL,
                         NULL,
                         p_Inn_Num,
                         NULL,
                         NULL,
                         NULL,
                         NULL,
                         DECODE (p_Last, 1, '1', '2'),
                         p_Src,
                         NULL,
                         p_Inn_Ndt,
                         NULL,
                         NULL);
        END IF;

        SELECT    'SCD_ST list =['
               || LISTAGG (scd_st || '=' || amnt, ', ')
               || '], sc_st='
               || MAX (Sc_st)
          INTO l_res
          FROM (  SELECT ddd.scd_st,
                         COUNT (Ddd.Scd_Id)     amnt,
                         MAX (Sc.Sc_st)         Sc_st
                    FROM Sc_Document Ddd
                         JOIN Socialcard Sc ON Sc.Sc_Id = Ddd.Scd_Sc
                         JOIN Sc_Change Scc ON Sc.Sc_Scc = Scc.Scc_Id
                         JOIN Sc_Identity i ON Scc.Scc_Sci = i.Sci_Id
                   WHERE ddd.scd_sc = p_Sc
                GROUP BY ddd.scd_st);

        LOG ('SC document statuses = ' || l_res);
    END;

    -------------------------------------------------------------------------------
    --           Збереження документа, що посвідчує особу
    -------------------------------------------------------------------------------
    PROCEDURE Save_Document (p_Sc        IN NUMBER,
                             p_Doc_Ndt   IN NUMBER,
                             p_Doc_Ser   IN VARCHAR2,
                             p_Doc_Num   IN VARCHAR2,
                             p_Doc_Is    IN VARCHAR2,
                             p_Doc_Bdt   IN DATE,
                             p_Doc_Edt   IN DATE,
                             p_Note      IN VARCHAR2,
                             p_Src       IN VARCHAR2,
                             p_Last      IN NUMBER)
    IS
        r_Scd   v_Sc_Document%ROWTYPE;
        l_res   VARCHAR2 (500);
    BEGIN
        -- если актуального паспорта нет то ищем просто паспорт у этого документва с таким же значением для перевода его в статус актуальный
        -- если анкета не актуальная, но документ актуальный то статус не меняем, если анкета актуальная а инн не актуальный повышаем статус документа до актуального
        IKIS_SYS.IKIS_PROCEDURE_LOG.LOG (
            UPPER ('USS_PERSON.Load$socialcard.Save_Document'),
            'SC',
            gLogSes,
               'Start. p_Sc='
            || p_Sc
            || ', p_Doc_Ndt='
            || p_Doc_Ndt
            || ', p_Doc_Ser='
            || p_Doc_Ser
            || ', p_Doc_Num='
            || p_Doc_Num
            || ', p_Doc_Is='
            || p_Doc_Is
            || ', p_Doc_Bdt='
            || p_Doc_Bdt
            || ', p_Doc_Edt='
            || p_Doc_Edt
            || ', p_Note='
            || p_Note
            || ', p_Src='
            || p_Src
            || ', p_Last='
            || p_Last,
            NULL);

        BEGIN
            -- поиск документа по ндт среди (13 clas)
            SELECT d.Scd_Id
              INTO r_Scd.Scd_Id
              FROM (SELECT d.Scd_Id,
                           ROW_NUMBER ()
                               OVER (
                                   ORDER BY
                                       --
                                       CASE
                                           WHEN d.Scd_Ndt = p_Doc_Ndt THEN 0
                                           ELSE 1
                                       END,
                                       Tt.Ndt_Order)    AS Rn
                      FROM v_Sc_Document  d
                           JOIN Uss_Ndi.v_Ndi_Document_Type Tt
                               ON Tt.Ndt_Id = d.Scd_Ndt     -- выбор по классу
                           JOIN Uss_Ndi.v_Ndi_Document_Type Tc
                               ON     Tc.Ndt_Ndc = Tt.Ndt_Ndc -- в рамках однотипной группы если указана или самого себя
                                  AND COALESCE (Tc.Ndt_Uniq_Group,
                                                TO_CHAR (Tc.Ndt_Id)) =
                                      COALESCE (Tt.Ndt_Uniq_Group,
                                                TO_CHAR (Tt.Ndt_Id))
                     WHERE     d.Scd_Sc = p_Sc
                           AND d.Scd_St IN ('1'                       /*,'2'*/
                                               ) --# 86550 - вероятно, надеются, что тут случится магия и поток какашек станет меньше
                           AND Tc.Ndt_Id = p_Doc_Ndt
                           AND UPPER (
                                   REPLACE (
                                       REPLACE (d.Scd_Seria || d.Scd_Number,
                                                '-',
                                                ''),
                                       ' ',
                                       '')) =
                               UPPER (
                                   REPLACE (
                                       REPLACE (p_Doc_Ser || p_Doc_Num,
                                                '-',
                                                ''),
                                       ' ',
                                       ''))) d
             WHERE Rn = 1;

            IKIS_SYS.IKIS_PROCEDURE_LOG.LOG (
                UPPER ('USS_PERSON.Load$socialcard.Save_Document'),
                'SC',
                gLogSes,
                'Scd founded. r_Scd.Scd_Id=' || r_Scd.Scd_Id,
                NULL);

            -- для последнего обновления, повышаем уровень документа до 1 - актуальный
            -- обнавляем параметры документа если изменения последние
            UPDATE Sc_Document Ddd
               SET Ddd.Scd_St = '1',
                   Ddd.Scd_Ndt = p_Doc_Ndt,
                   Ddd.Scd_Issued_Dt =
                       COALESCE (p_Doc_Bdt, Ddd.Scd_Issued_Dt),
                   Ddd.Scd_Issued_Who =
                       COALESCE (p_Doc_Is, Ddd.Scd_Issued_Who),
                   Ddd.Scd_Start_Dt = COALESCE (p_Doc_Bdt, Ddd.Scd_Issued_Dt),
                   Ddd.Scd_Stop_Dt = COALESCE (p_Doc_Edt, Ddd.Scd_Stop_Dt) --,
             --ddd.scd_note=ddd.scd_note||case when p_note is not null and ddd.scd_note is not null then chr(10) else null end||p_note
             WHERE     Ddd.Scd_Id = r_Scd.Scd_Id
                   AND Ddd.Scd_Sc = p_Sc
                   AND p_Last = 1;


            IKIS_SYS.IKIS_PROCEDURE_LOG.LOG (
                UPPER ('USS_PERSON.Load$socialcard.Save_Document'),
                'SC',
                gLogSes,
                'Updated rows for founded SC ID amount = ' || SQL%ROWCOUNT,
                NULL);
        -- не нашли document, упали в ошибку
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                IKIS_SYS.IKIS_PROCEDURE_LOG.LOG (
                    UPPER ('USS_PERSON.Load$socialcard.Save_Document'),
                    'SC',
                    gLogSes,
                    'Scd not found.',
                    NULL);

                -- вставка документa
                INSERT INTO Sc_Document (Scd_Id,
                                         Scd_Sc,
                                         Scd_Name,
                                         Scd_Seria,
                                         Scd_Number,
                                         Scd_Issued_Dt,
                                         Scd_Issued_Who,
                                         Scd_Start_Dt,
                                         Scd_Stop_Dt,
                                         Scd_St,
                                         Scd_Src,
                                         Scd_Note,
                                         Scd_Ndt,
                                         Scd_Doc,
                                         Scd_Dh)
                     VALUES (NULL,
                             p_Sc,
                             NULL,
                             p_Doc_Ser,
                             p_Doc_Num,
                             p_Doc_Bdt,
                             p_Doc_Is,
                             p_Doc_Bdt,
                             p_Doc_Edt,
                             DECODE (p_Last, 1, '1', '2'),
                             p_Src,
                             p_Note,
                             p_Doc_Ndt,
                             NULL,
                             NULL)
                  RETURNING Scd_Id
                       INTO r_Scd.Scd_Id;
        END;

        -- все остальные документы данной группы переводим в неактуальные
        -- а с похожими номерами в рамках группы в дубли
        UPDATE Sc_Document Ddd
           SET Ddd.Scd_St =
                   CASE
                       WHEN UPPER (
                                REPLACE (
                                    REPLACE (Ddd.Scd_Seria || Ddd.Scd_Number,
                                             '-',
                                             ''),
                                    ' ',
                                    '')) <>
                            UPPER (
                                REPLACE (
                                    REPLACE (p_Doc_Ser || p_Doc_Num, '-', ''),
                                    ' ',
                                    ''))
                       THEN
                           '2'
                       ELSE
                           '4'
                   END
         WHERE     Ddd.Scd_Id <> r_Scd.Scd_Id
               AND Ddd.Scd_Sc = p_Sc
               AND Ddd.Scd_St IN ('1'                                 /*,'2'*/
                                     ) --# 86550 - вероятно, надеются, что тут случится магия и поток какашек станет меньше
               AND p_Last = 1
               AND Ddd.Scd_Ndt IN
                       (SELECT Tc.Ndt_Id
                          FROM Uss_Ndi.v_Ndi_Document_Type  Tt
                               JOIN Uss_Ndi.v_Ndi_Document_Type Tc
                                   ON     Tc.Ndt_Ndc = Tt.Ndt_Ndc -- в рамках однотипной группы если указана или самого себя
                                      AND COALESCE (Tc.Ndt_Uniq_Group,
                                                    TO_CHAR (Tc.Ndt_Id)) =
                                          COALESCE (Tt.Ndt_Uniq_Group,
                                                    TO_CHAR (Tt.Ndt_Id))
                         WHERE Tt.Ndt_Id = p_Doc_Ndt);

        IKIS_SYS.IKIS_PROCEDURE_LOG.LOG (
            UPPER ('USS_PERSON.Load$socialcard.Save_Document'),
            'SC',
            gLogSes,
            'Updated rows for EMPTY SCD ID amount = ' || SQL%ROWCOUNT,
            NULL);

        -- 15092022 - Shy принял решение что обновление документа не является меткой смены анкеты
        -- сбрасываем инфу по анкете для образования среза (пересчет ИНФО)
        --if l_last = 1 then
        --  r_scc.scc_id := Null;
        --end if;
        SELECT    'SCD_ST list ='
               || LISTAGG (scd_st || '=' || amnt, ', ')
               || ', sc_st='
               || MAX (Sc_st)
          INTO l_res
          FROM (  SELECT ddd.scd_st,
                         COUNT (Ddd.Scd_Id)     amnt,
                         MAX (Sc.Sc_st)         Sc_st
                    FROM Sc_Document Ddd
                         JOIN Socialcard Sc ON Sc.Sc_Id = Ddd.Scd_Sc
                         JOIN Sc_Change Scc ON Sc.Sc_Scc = Scc.Scc_Id
                         JOIN Sc_Identity i ON Scc.Scc_Sci = i.Sci_Id
                   WHERE ddd.scd_sc = p_Sc
                GROUP BY ddd.scd_st);

        IKIS_SYS.IKIS_PROCEDURE_LOG.LOG (
            UPPER ('USS_PERSON.Load$socialcard.Save_Document'),
            'SC',
            gLogSes,
            'SC document statuses = ' || l_res,
            NULL);
    END;

    -------------------------------------------------------------------------------
    --           Створення соціальної картки
    -------------------------------------------------------------------------------
    FUNCTION Create_Sc (p_Src         IN     VARCHAR2,
                        p_Sysdate     IN     DATE,
                        p_Sc_Unique   IN OUT VARCHAR2)
        RETURN NUMBER
    IS
        l_Sc   NUMBER;
    BEGIN
        INSERT INTO Socialcard (Sc_Id,
                                Sc_Unique,
                                Sc_Create_Dt,
                                Sc_Scc,
                                Sc_Src,
                                Sc_St)
             VALUES (l_Sc,
                     NULL,
                     p_Sysdate,
                     -1,
                     p_Src,
                     '4')
             RETURN Sc_Id
               INTO l_Sc;

        UPDATE Socialcard Ddd
           SET Ddd.Sc_Unique =
                   COALESCE (p_Sc_Unique, 'T' || TO_CHAR (Ddd.Sc_Id))
         WHERE Ddd.Sc_Id = l_Sc AND Ddd.Sc_Unique IS NULL
        RETURN Sc_Unique
          INTO p_Sc_Unique;

        INSERT INTO Sc_Feature (Scf_Sc)
             VALUES (l_Sc);

        RETURN l_Sc;
    END;

    -------------------------------------------------------------------------------
    --           Отримання зрізу соцкартки
    -------------------------------------------------------------------------------
    FUNCTION Get_Sc_Change (p_Sc        IN     NUMBER,
                            p_Src_Dt    IN     DATE,
                            p_Sysdate   IN     DATE,
                            p_Last         OUT NUMBER)
        RETURN v_Sc_Change%ROWTYPE
    IS
        r_Scc   v_Sc_Change%ROWTYPE;
    BEGIN
        IKIS_SYS.IKIS_PROCEDURE_LOG.LOG (
            UPPER ('USS_PERSON.Load$socialcard.Get_Sc_Change'),
            'SC',
            gLogSes,
               'Start. p_Sc='
            || p_Sc
            || ', p_Src_Dt='
            || p_Src_Dt
            || ', p_Sysdate='
            || p_Sysdate,
            NULL);

        -- вичитка анкети по персоні
        SELECT Scc.*
          INTO r_Scc
          FROM Socialcard Sc JOIN v_Sc_Change Scc ON Scc.Scc_Id = Sc.Sc_Scc
         WHERE Sc.Sc_Id = p_Sc;

        IKIS_SYS.IKIS_PROCEDURE_LOG.LOG (
            UPPER ('USS_PERSON.Load$socialcard.Get_Sc_Change'),
            'SC',
            gLogSes,
               'SCC Data. r_Scc.Scc_Src_Dt='
            || r_Scc.Scc_Src_Dt
            || ', r_Scc.Scc_Create_Dt='
            || r_Scc.Scc_Create_Dt,
            NULL);

        IF COALESCE (r_Scc.Scc_Src_Dt, r_Scc.Scc_Create_Dt) <=
           COALESCE (p_Src_Dt, p_Sysdate)
        THEN
            p_Last := 1;                    -- последнее изменение по человеку
        ELSE
            p_Last := 0;                         -- ранее заведенное изменение

            -- доработано что за базу для заполнения анкеты по персоны мы берем анкету не последнюю в общем жизненном цикле
            -- а последнюю до даты сорца при пустом то до систейта.
            SELECT Scc.*
              INTO r_Scc
              FROM Sc_Change Scc
             WHERE Scc.Scc_Id =
                   (SELECT COALESCE (MAX (Scc_Id), -1)
                      FROM Sc_Change c
                     WHERE     c.Scc_Sc = p_Sc
                           AND COALESCE (c.Scc_Src_Dt, c.Scc_Create_Dt) <=
                               COALESCE (p_Src_Dt, p_Sysdate));
        END IF;

        IKIS_SYS.IKIS_PROCEDURE_LOG.LOG (
            UPPER ('USS_PERSON.Load$socialcard.Get_Sc_Change'),
            'SC',
            gLogSes,
            'Ger result. p_Last = ' || p_Last,
            NULL);

        RETURN r_Scc;
    END;

    -------------------------------------------------------------------------------
    --           Збереження зрізу соцкартки
    -------------------------------------------------------------------------------
    PROCEDURE Save_Sc_Change (p_Sc        IN            NUMBER,
                              p_Scc       IN OUT NOCOPY v_Sc_Change%ROWTYPE,
                              p_Last      IN            NUMBER,
                              p_Src       IN            VARCHAR2,
                              p_Src_Dt    IN            DATE,
                              p_Sysdate   IN            DATE)
    IS
    BEGIN
        -- вставка анкеты (срез информации о персоне)
        INSERT INTO Sc_Change (Scc_Id,
                               Scc_Sc,
                               Scc_Create_Dt,
                               Scc_Src,
                               Scc_Sct,
                               Scc_Sci,
                               Scc_Scb,
                               Scc_Sca,
                               Scc_Sch,
                               Scc_Scp,
                               Scc_Src_Dt)
             VALUES (p_Scc.Scc_Id,
                     p_Sc,
                     p_Sysdate,
                     p_Src,
                     p_Scc.Scc_Sct,
                     p_Scc.Scc_Sci,
                     p_Scc.Scc_Scb,
                     p_Scc.Scc_Sca,
                     p_Scc.Scc_Sch,
                     p_Scc.Scc_Scp,
                     COALESCE (p_Src_Dt, p_Sysdate))
             RETURN Scc_Id
               INTO p_Scc.Scc_Id;

        -- если анкета последняя то на нее ссылаемя у карточки
        IF p_Last = 1
        THEN
            -- сылка на новую анкету
            UPDATE Socialcard Ddd
               SET Ddd.Sc_Scc = p_Scc.Scc_Id
             WHERE     Ddd.Sc_Id = p_Sc
                   AND Ddd.Sc_Scc <> COALESCE (p_Scc.Scc_Id, -1);
        END IF;
    END;

    -------------------------------------------------------------------------------
    --           Оновлення інформації
    -------------------------------------------------------------------------------
    PROCEDURE Refresh_Sc_Info (p_Sc IN NUMBER, p_Sysdate IN DATE)
    IS
    BEGIN
        -- переформировываем инфо
        DELETE FROM Sc_Info i
              WHERE i.Sco_Id = p_Sc;

        INSERT INTO Sc_Info (Sco_Id,
                             Sco_Fn,
                             Sco_Mn,
                             Sco_Ln,
                             Sco_Nationality,
                             Sco_Gender,
                             Sco_Birth_Dt,
                             Sco_Pasp_Seria,
                             Sco_Pasp_Number,
                             Sco_Status,
                             Sco_Numident,
                             Sco_Mondify_Dt,
                             Sco_Unique)
            WITH
                Scd_Doc
                AS
                    (SELECT /*+ materialize*/
                            Scd.*
                       FROM (SELECT ROW_NUMBER ()
                                        OVER (
                                            ORDER BY
                                                --
                                                CASE
                                                    WHEN Ndt.Ndt_Uniq_Group =
                                                         'PASP'
                                                    THEN
                                                        1
                                                    WHEN Ndt.Ndt_Uniq_Group =
                                                         'BRCR'
                                                    THEN
                                                        2
                                                    WHEN Ndt.Ndt_Uniq_Group =
                                                         'OVRP'
                                                    THEN
                                                        3
                                                    ELSE
                                                        9
                                                END,
                                                Ndt.Ndt_Order)    AS Rn,
                                    Scd.*
                               FROM Sc_Document  Scd
                                    JOIN Uss_Ndi.v_Ndi_Document_Type Ndt
                                        ON     Ndt.Ndt_Id = Scd.Scd_Ndt
                                           AND Ndt.Ndt_Ndc = 13
                              WHERE Scd.Scd_St = '1' AND Scd.Scd_Sc = p_Sc)
                            Scd
                      WHERE Scd.Rn = 1)
            SELECT Sc.Sc_Id,
                   i.Sci_Fn,
                   i.Sci_Mn,
                   i.Sci_Ln,
                   n.Dic_Sname,
                   g.Dic_Sname,
                   b.Scb_Dt,
                   Scd_Doc.Scd_Seria,
                   Scd_Doc.Scd_Number,
                   Scs.Dic_Sname,
                   Inn.Scd_Number,
                   p_Sysdate,
                   Sc.Sc_Unique
              FROM Socialcard  Sc
                   JOIN Sc_Change Scc ON Scc.Scc_Id = Sc.Sc_Scc
                   JOIN Uss_Ndi.v_Ddn_Sc_St Scs ON Scs.Dic_Value = Sc.Sc_St
                   JOIN Sc_Identity i ON i.Sci_Id = Scc.Scc_Sci
                   JOIN Uss_Ndi.v_Ddn_Nationality n
                       ON n.Dic_Value = i.Sci_Nationality
                   JOIN Uss_Ndi.v_Ddn_Gender g ON g.Dic_Value = i.Sci_Gender
                   JOIN Sc_Birth b ON b.Scb_Id = Scc.Scc_Scb
                   JOIN Sc_Death d ON d.Sch_Id = Scc.Scc_Sch
                   LEFT JOIN Sc_Document Inn
                       ON     Inn.Scd_Sc = Sc.Sc_Id
                          AND Inn.Scd_Ndt = 5
                          AND Inn.Scd_St = '1'
                   LEFT JOIN Scd_Doc ON Scd_Doc.Scd_Sc = Sc.Sc_Id
             WHERE Sc.Sc_St IN ('1', '4') AND Sc.Sc_Id = p_Sc;
    END;


    -------------------------------------------------------------------------------
    --     Пошук/оновлення/створення соцкартки
    --    (операція залежить від режиму p_Mode)
    -------------------------------------------------------------------------------
    FUNCTION Load_Sc_Intrnl (
        p_Fn                IN     VARCHAR2,
        p_Ln                IN     VARCHAR2,
        p_Mn                IN     VARCHAR2,
        p_Gender            IN     VARCHAR,
        p_Nationality       IN     VARCHAR2,
        p_Src_Dt            IN     DATE,
        p_Birth_Dt          IN     DATE,
        p_Inn_Num           IN     VARCHAR2,
        p_Inn_Ndt           IN     NUMBER,
        p_Doc_Ser           IN     VARCHAR2,
        p_Doc_Num           IN     VARCHAR2,
        p_Doc_Ndt           IN     NUMBER,
        p_Doc_Unzr          IN     VARCHAR2 DEFAULT NULL,             --ignore
        p_Doc_Is            IN     VARCHAR2 DEFAULT NULL,
        p_Doc_Bdt           IN     DATE DEFAULT NULL,
        p_Doc_Edt           IN     DATE DEFAULT NULL,
        p_Src               IN     VARCHAR2,
        p_Sc                IN OUT Socialcard.Sc_Id%TYPE,
        p_Sc_Unique         IN OUT Socialcard.Sc_Unique%TYPE,
        p_Sc_Scc               OUT Socialcard.Sc_Scc%TYPE,
        p_Mode              IN     NUMBER DEFAULT 0,
        p_Note              IN     VARCHAR2 DEFAULT NULL,
        p_Email             IN     VARCHAR2 DEFAULT NULL,
        p_Is_Email_Inform   IN     VARCHAR2 DEFAULT NULL,
        p_Phone             IN     VARCHAR2 DEFAULT NULL,             --ignore
        p_Is_Phone_Inform   IN     VARCHAR2 DEFAULT NULL              --ignore
                                                        )
        RETURN NUMBER
    IS
        l_Last      NUMBER (1) := 1;
        l_Sysdate   DATE := SYSDATE;
        l_Sc        NUMBER;
        l_Inn_Num   VARCHAR2 (10);
        l_is_new    NUMBER (1) := 0;
        l_res       VARCHAR2 (500);

        r_Scc       v_Sc_Change%ROWTYPE;
    BEGIN
        IKIS_SYS.IKIS_PROCEDURE_LOG.LOG (
            UPPER ('USS_PERSON.Load$socialcard.Load_Sc_Intrnl'),
            'SC',
            gLogSes,
               'p_Sc='
            || p_Sc
            || ', p_Fn='
            || p_Fn
            || ', p_Ln='
            || p_Ln
            || ', p_Mn='
            || p_Mn
            || ', p_Birth_Dt='
            || p_Birth_Dt
            || ', p_Inn_Num='
            || p_Inn_Num
            || ', p_Inn_Ndt='
            || p_Inn_Ndt
            || ', p_Doc_Num='
            || p_Doc_Num
            || ', p_Doc_Ser='
            || p_Doc_Ser
            || ', p_Doc_Ndt='
            || p_Doc_Ndt
            || ', p_Doc_Is='
            || p_Doc_Is
            || ', p_Doc_Bdt='
            || p_Doc_Bdt
            || ', p_Doc_Edt='
            || p_Doc_Edt
            || ', p_Gender='
            || p_Gender
            || ', p_Nationality='
            || p_Nationality
            || ', p_Src_Dt='
            || p_Src_Dt,
            NULL);
        p_Sc_Scc := NULL;
        g_Pib_Mismatch_On_Ipn := FALSE;
        g_Ipn_Invalid := FALSE;
        g_Is_New_Sc := FALSE;

        IF p_Inn_Num IS NOT NULL
        THEN
            l_Inn_Num := NULLIF (TRIM (p_Inn_Num), '0000000000');

            IF NOT REGEXP_LIKE (l_Inn_Num, '^[0-9]{10}')
            THEN
                l_Inn_Num := NULL;
            END IF;
        END IF;

        -- проверки на корректность входящих параметров, пока что через иф но в дальнейшем на метод.
        -- должен быть хоть одинн нормальный документ
        -- в противном случае возвращается "-2"
        IF NOT (   --ІПН
                   (    l_Inn_Num IS NOT NULL
                    AND NVL (p_Inn_Ndt, -1) IN (5, 10366))
                OR --Документ
                   (    REPLACE (REPLACE (p_Doc_Ser || p_Doc_Num, '-', ''),
                                 ' ',
                                 '')
                            IS NOT NULL
                    AND --Документи що посвідчують особу
                        NVL (p_Doc_Ndt, -1) IN (6,
                                                7,
                                                8,
                                                9,
                                                11,
                                                13,
                                                37,
                                                673,
                                                10095,
                                                10192))
                OR (p_Sc IS NOT NULL))
        THEN
            IKIS_SYS.IKIS_PROCEDURE_LOG.LOG (
                UPPER ('USS_PERSON.Load$socialcard.Load_Sc_Intrnl'),
                'SC',
                gLogSes,
                'Return with result = -2',
                NULL);

            RETURN -2;
        END IF;

        --ЯКЩО ВКАЗАНО ІД СОЦКАРТКИ
        IF p_Sc IS NOT NULL
        THEN
            SELECT Sc.Sc_Id, Sc.Sc_Unique, Sc.Sc_Scc
              INTO l_Sc, p_Sc_Unique, p_Sc_Scc
              FROM Socialcard Sc
             WHERE Sc.Sc_Id = p_Sc;
        ELSE
            --ПОШУК СОЦКАРТКИ
            l_Sc :=
                Search_Sc (p_Ipn_Num     => l_Inn_Num,
                           p_Doc_Ndt     => p_Doc_Ndt,
                           p_Doc_Ser     => p_Doc_Ser,
                           p_Doc_Num     => p_Doc_Num,
                           p_Ln          => p_Ln,
                           p_Fn          => p_Fn,
                           p_Mn          => p_Mn,
                           p_Birth_Dt    => p_Birth_Dt,
                           p_Sc_Unique   => p_Sc_Unique,
                           p_Sc_Scc      => p_Sc_Scc);
        END IF;

        IKIS_SYS.IKIS_PROCEDURE_LOG.LOG (
            UPPER ('USS_PERSON.Load$socialcard.Load_Sc_Intrnl'),
            'SC',
            gLogSes,
            'SC is: l_Sc=' || l_Sc,
            NULL);

        --ПОМИЛКА ПОШУКУ ОСОБИ
        IF l_Sc <= 0
        THEN
            IKIS_SYS.IKIS_PROCEDURE_LOG.LOG (
                UPPER ('USS_PERSON.Load$socialcard.Load_Sc_Intrnl'),
                'SC',
                gLogSes,
                'Return with result by l_Sc = ' || l_Sc,
                NULL);
            RETURN l_Sc;
        END IF;

        --ПЕРЕВІРКА КОРЕКТНОСТІ ІПН #94508
        IF     l_Inn_Num IS NOT NULL
           AND NOT Validate_Ipn (l_Inn_Num, p_Birth_Dt, p_Gender)
           AND NVL (p_Inn_Ndt, -1) NOT IN (10366)
        THEN
            g_Ipn_Invalid := TRUE;
            l_Inn_Num := NULL;
        END IF;

        --СТВОРЕННЯ СОЦКАРТКИ, ЯКЩО НЕОБХІДНО
        IF     p_Mode IN (c_Mode_Search_Update_Create, c_Mode_Search_Create)
           AND l_Sc IS NULL
        THEN
            --Якщо достатньо даних для створення соцкартки
            IF     (   --ІПН
                       (    l_Inn_Num IS NOT NULL
                        AND NVL (p_Inn_Ndt, -1) IN (5, 10366))
                    OR --документ
                       (    REPLACE (
                                REPLACE (p_Doc_Ser || p_Doc_Num, '-', ''),
                                ' ',
                                '')
                                IS NOT NULL
                        AND --документи що посвідчують особу
                            NVL (p_Doc_Ndt, -1) IN (6,
                                                    7,
                                                    8,
                                                    9,
                                                    11,
                                                    13,
                                                    37,
                                                    673,
                                                    10095,
                                                    10192)))
               --ім'я та прізвище
               AND (p_Ln IS NOT NULL AND p_Fn IS NOT NULL)
            THEN
                l_Sc :=
                    Create_Sc (p_Src         => p_Src,
                               p_Sysdate     => l_Sysdate,
                               p_Sc_Unique   => p_Sc_Unique);
                IKIS_SYS.IKIS_PROCEDURE_LOG.LOG (
                    UPPER ('USS_PERSON.Load$socialcard.Load_Sc_Intrnl'),
                    'SC',
                    gLogSes,
                    'SC created: l_Sc=' || l_Sc,
                    NULL);
                l_is_new := 1;
                g_Is_New_Sc := TRUE;
                p_Sc := l_Sc;
            ELSE
                --Якщо даних недостатно повертаємо помилку
                IKIS_SYS.IKIS_PROCEDURE_LOG.LOG (
                    UPPER ('USS_PERSON.Load$socialcard.Load_Sc_Intrnl'),
                    'SC',
                    gLogSes,
                    'Not enough data to create SC',
                    NULL);
                RETURN -2;
            END IF;
        END IF;

        --АКТУАЛІЗАЦІЯ СОКАРТКИ
        IF     (   p_Mode IN
                       (c_Mode_Search_Update_Create, c_Mode_Search_Update)
                OR (p_Mode = c_Mode_Search_Create AND l_is_new = 1) -- IC #101419
                                                                   )
           AND l_Sc IS NOT NULL
        THEN
            -- встановленнчя ксс
            UPDATE Socialcard Ddd
               SET Ddd.Sc_Unique =
                       CASE
                           WHEN Ddd.Sc_Unique LIKE 'T%'
                           THEN
                               COALESCE (p_Sc_Unique, Ddd.Sc_Unique)
                           ELSE
                               Ddd.Sc_Unique
                       END
             WHERE Ddd.Sc_Id = l_Sc AND Ddd.Sc_Unique IS NULL
            RETURN Sc_Unique
              INTO p_Sc_Unique;

            --ОТРИМАННЯ ЗРІЗУ СОЦКАРТКИ ДО ЯКОГО БУДУТЬ ЗБЕРІГАТИСЬ ДАНІ
            r_Scc :=
                Get_Sc_Change (p_Sc        => l_Sc,
                               p_Last      => l_Last,
                               p_Src_Dt    => p_Src_Dt,
                               p_Sysdate   => l_Sysdate);
            IKIS_SYS.IKIS_PROCEDURE_LOG.LOG (
                UPPER ('USS_PERSON.Load$socialcard.Load_Sc_Intrnl'),
                'SC',
                gLogSes,
                'SCC getted: r_Scc.scc_id=' || r_Scc.scc_id,
                NULL);

            --ЗБЕРЕЖЕННЯ ДН
            IF p_Birth_Dt IS NOT NULL
            THEN
                Save_Sc_Birth (p_Sc         => l_Sc,
                               p_Birth_Dt   => p_Birth_Dt,
                               p_Src        => p_Src,
                               p_Scc        => r_Scc);
            END IF;

            --ЗБЕРЕЖЕННЯ ПІБ, СТАТІ ТА ГРОМАДЯНСТВА
            IF p_Ln IS NOT NULL OR p_Fn IS NOT NULL OR p_Mn IS NOT NULL
            THEN
                IKIS_SYS.IKIS_PROCEDURE_LOG.LOG (
                    UPPER ('USS_PERSON.Load$socialcard.Load_Sc_Intrnl'),
                    'SC',
                    gLogSes,
                    'Before save identity',
                    NULL);
                Save_Sc_Identity (p_Sc            => l_Sc,
                                  p_Ln            => p_Ln,
                                  p_Fn            => p_Fn,
                                  p_Mn            => p_Mn,
                                  p_Nationality   => p_Nationality,
                                  p_Gender        => p_Gender,
                                  p_Scc           => r_Scc);
            END IF;

            --ЗБЕРЕЖЕННЯ КОНТАКТІВ
            IF p_Email IS NOT NULL OR p_Is_Email_Inform = 'F'
            THEN
                Save_Sc_Contacts (p_Sc                => l_Sc,
                                  p_Email             => p_Email,
                                  p_Is_Email_Inform   => p_Is_Email_Inform,
                                  p_Scc               => r_Scc);
            END IF;

            --ЗБЕРЕЖЕННЯ ІПН
            IKIS_SYS.IKIS_PROCEDURE_LOG.LOG (
                UPPER ('USS_PERSON.Load$socialcard.Load_Sc_Intrnl'),
                'SC',
                gLogSes,
                'Before save IPN',
                NULL);

            IF l_Inn_Num IS NOT NULL AND p_Inn_Ndt IS NOT NULL
            THEN
                Save_Ipn (p_Sc        => l_Sc,
                          p_Inn_Ndt   => p_Inn_Ndt,
                          p_Inn_Num   => l_Inn_Num,
                          p_Src       => p_Src,
                          p_Last      => l_Last);
            ELSE
                IKIS_SYS.IKIS_PROCEDURE_LOG.LOG (
                    UPPER ('USS_PERSON.Load$socialcard.Load_Sc_Intrnl'),
                    'SC',
                    gLogSes,
                    'Scip save IPN',
                    NULL);
            END IF;

            IKIS_SYS.IKIS_PROCEDURE_LOG.LOG (
                UPPER ('USS_PERSON.Load$socialcard.Load_Sc_Intrnl'),
                'SC',
                gLogSes,
                'Before save document',
                NULL);

            --ЗБЕРЕЖЕННЯ ДОКУМЕНТУ ЩО ПОСВІДЧУЄ ОСОБУ
            IF     REPLACE (REPLACE (p_Doc_Ser || p_Doc_Num, '-', ''),
                            ' ',
                            '')
                       IS NOT NULL
               AND p_Doc_Ndt IS NOT NULL
            THEN
                Save_Document (p_Sc        => l_Sc,
                               p_Doc_Ndt   => p_Doc_Ndt,
                               p_Doc_Ser   => p_Doc_Ser,
                               p_Doc_Num   => p_Doc_Num,
                               p_Doc_Is    => p_Doc_Is,
                               p_Doc_Bdt   => p_Doc_Bdt,
                               p_Doc_Edt   => p_Doc_Edt,
                               p_Note      => p_Note,
                               p_Src       => p_Src,
                               p_Last      => l_Last);
            ELSE
                IKIS_SYS.IKIS_PROCEDURE_LOG.LOG (
                    UPPER ('USS_PERSON.Load$socialcard.Load_Sc_Intrnl'),
                    'SC',
                    gLogSes,
                    'Scip save document',
                    NULL);
            END IF;

            IKIS_SYS.IKIS_PROCEDURE_LOG.LOG (
                UPPER ('USS_PERSON.Load$socialcard.Load_Sc_Intrnl'),
                'SC',
                gLogSes,
                'Before create changes: r_Scc.Scc_Id=' || r_Scc.Scc_Id,
                NULL);

            --СТВОРЕННЯ ЗРІЗУ СОЦКАРТКИ
            IF r_Scc.Scc_Id IS NULL
            THEN
                Save_Sc_Change (p_Sc        => l_Sc,
                                p_Scc       => r_Scc,
                                p_Src       => p_Src,
                                p_Src_Dt    => p_Src_Dt,
                                p_Sysdate   => l_Sysdate,
                                p_Last      => l_Last);
            ELSE
                IKIS_SYS.IKIS_PROCEDURE_LOG.LOG (
                    UPPER ('USS_PERSON.Load$socialcard.Load_Sc_Intrnl'),
                    'SC',
                    gLogSes,
                    'Scip save changes',
                    NULL);
            END IF;

            IKIS_SYS.IKIS_PROCEDURE_LOG.LOG (
                UPPER ('USS_PERSON.Load$socialcard.Load_Sc_Intrnl'),
                'SC',
                gLogSes,
                'Before refresh sc: l_Last=' || l_Last,
                NULL);

            --ОНОВЛЕННЯ ІНФОРМАЦІЇ
            IF l_Last = 1
            THEN
                Refresh_Sc_Info (p_Sc => l_Sc, p_Sysdate => l_Sysdate);
            END IF;

            -- ОПРЕДЕЛЯЕМ ЗНАЧЕНИЕ АНКЕТЫ ПЕРСОНЫ КОТОРАЯ БЫЛА СОЗДАНА ИЛИ НА ОСНОВАНИИ КОТОРОЙ БЫЛО НАЙДЕНО ПЕРСОНУ
            p_Sc_Scc := r_Scc.Scc_Id;
        END IF;

        IF p_Sc_Scc IS NULL AND p_Mode = c_Mode_Search_Create
        THEN
            SELECT MAX (Sc.Sc_Scc)
              INTO p_Sc_Scc
              FROM Socialcard Sc
             WHERE Sc.Sc_Id = l_Sc;
        END IF;


        SELECT    'SCD_ST list =['
               || LISTAGG (scd_st || '=' || amnt, ', ')
               || '], sc_st='
               || MAX (Sc_st)
          INTO l_res
          FROM (  SELECT ddd.scd_st,
                         COUNT (Ddd.Scd_Id)     amnt,
                         MAX (Sc.Sc_st)         Sc_st
                    FROM Sc_Document Ddd
                         JOIN Socialcard Sc ON Sc.Sc_Id = Ddd.Scd_Sc
                         JOIN Sc_Change Scc ON Sc.Sc_Scc = Scc.Scc_Id
                         JOIN Sc_Identity i ON Scc.Scc_Sci = i.Sci_Id
                   WHERE ddd.scd_sc = l_Sc
                GROUP BY ddd.scd_st);

        IKIS_SYS.IKIS_PROCEDURE_LOG.LOG (
            UPPER ('USS_PERSON.Load$socialcard.Save_Ipn'),
            'SC',
            gLogSes,
            'SC card statuses = ' || l_res,
            NULL);

        RETURN l_Sc;
    END;
BEGIN
    -- Initialization
    NULL;
END;
/