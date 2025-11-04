/* Formatted on 8/12/2025 5:56:55 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_PERSON.LOAD$SOCIALCARD_QQ
IS
    -- Author  : JSHPAK
    -- Created : 14.12.2021 16:27:17
    -- Purpose :

    c_Mode_Search_Update_Create   CONSTANT NUMBER := 0; -- изначальный режим, поиск, нашли то актуализируем, ненашли то создаем и наполняем
    c_Mode_Search                 CONSTANT NUMBER := 1; -- первый дополнительный режим, только поиск
    c_Mode_Search_Update          CONSTANT NUMBER := 2; -- второй дополнительный режим, поиск при успешном нахождении актуализация, если не нашли то НЕ СОЗДАЕМ  новую персону

    g_Pib_Mismatch_On_Ipn                  BOOLEAN;
    g_Ipn_Invalid                          BOOLEAN;

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
