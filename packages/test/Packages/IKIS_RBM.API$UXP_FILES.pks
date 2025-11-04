/* Formatted on 8/12/2025 6:10:43 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_RBM.API$UXP_FILES
IS
    -- Author  : SHOSTAK
    -- Created : 26.12.2023 4:28:50 PM
    -- Purpose : API для роботи з файлами обмінів через Трембіту
    --          (використовується для порційних обмінів при великих об'ємах, через обмеження Трембіти на размір запиту та відповіді)

    PROCEDURE Create_File (p_Ur_Id IN NUMBER);

    PROCEDURE Create_File (p_Ur_Id IN NUMBER, p_Uf_Id OUT NUMBER);

    PROCEDURE Set_File_Content (p_Uf_Id IN NUMBER, p_Uf_Content IN BLOB);

    PROCEDURE Get_File_Portion (p_Ur_Id             IN     NUMBER,
                                p_Client_Code       IN     VARCHAR2,
                                p_Client_Subsys     IN     VARCHAR2,
                                p_Offset            IN     NUMBER,
                                p_Limit             IN     NUMBER,
                                p_Total_Size           OUT NUMBER,
                                p_Portion_Content      OUT BLOB);

    PROCEDURE Build_And_Zip_Csv (p_Uf_Id        IN NUMBER,
                                 p_Csv_Header   IN VARCHAR2,
                                 p_Csv_Data     IN SYS_REFCURSOR);

    PROCEDURE Save_Json_Array (
        p_Ur_Id             IN            NUMBER,
        p_Json_Array        IN OUT NOCOPY CLOB,
        p_Compression_Lvl   IN            NUMBER DEFAULT NULL);

    /*
    info:    Отримання ідентифікатору файла по запиту
    author:  sho
    */
    FUNCTION Get_Ur_Uf (p_Ur_Id IN NUMBER)
        RETURN NUMBER;

    /*
    info:    Отримання відповіді по дельті
    author:  sho
    request: #106637
    note:
    */
    FUNCTION Get_Delta_Answer (p_Request_Id     IN NUMBER,
                               p_Request_Body   IN CLOB)
        RETURN CLOB;

    /*
    info:    Отримання файлу відповіді по дельті
    author:  sho
    request: #106637
    note:
    */
    FUNCTION Get_Delta_Answer_File (p_Request_Id     IN NUMBER,
                                    p_Request_Body   IN CLOB)
        RETURN CLOB;
END Api$uxp_Files;
/


GRANT EXECUTE ON IKIS_RBM.API$UXP_FILES TO II01RC_RBM_INTERNAL
/

GRANT EXECUTE ON IKIS_RBM.API$UXP_FILES TO II01RC_RBM_SVC
/

GRANT EXECUTE ON IKIS_RBM.API$UXP_FILES TO SERVICE_PROXY
/

GRANT EXECUTE ON IKIS_RBM.API$UXP_FILES TO USS_ESR
/

GRANT EXECUTE ON IKIS_RBM.API$UXP_FILES TO USS_PERSON
/

GRANT EXECUTE ON IKIS_RBM.API$UXP_FILES TO USS_RNSP
/

GRANT EXECUTE ON IKIS_RBM.API$UXP_FILES TO USS_VISIT
/


/* Formatted on 8/12/2025 6:10:48 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_RBM.API$UXP_FILES
IS
    -------------------------------------------------------
    --  Створення файлу
    -------------------------------------------------------
    PROCEDURE Create_File (p_Ur_Id IN NUMBER)
    IS
    BEGIN
        INSERT INTO Uxp_Files (Uf_Id, Uf_Ur)
             VALUES (0, p_Ur_Id);
    END;

    PROCEDURE Create_File (p_Ur_Id IN NUMBER, p_Uf_Id OUT NUMBER)
    IS
    BEGIN
        INSERT INTO Uxp_Files (Uf_Id, Uf_Ur)
             VALUES (0, p_Ur_Id)
          RETURNING Uf_Id
               INTO p_Uf_Id;
    END;

    -------------------------------------------------------
    --  Збереження вмісту файлу
    -------------------------------------------------------
    PROCEDURE Set_File_Content (p_Uf_Id IN NUMBER, p_Uf_Content IN BLOB)
    IS
    BEGIN
        UPDATE Uxp_Files f
           SET f.Uf_Content = p_Uf_Content,
               f.Uf_Build_Dt = SYSDATE,
               f.Uf_Size = DBMS_LOB.Getlength (p_Uf_Content)
         WHERE f.Uf_Id = p_Uf_Id;
    END;

    -------------------------------------------------------
    --  Зчитування порції файлу
    -------------------------------------------------------
    PROCEDURE Get_File_Portion (p_Ur_Id             IN     NUMBER,
                                p_Client_Code       IN     VARCHAR2,
                                p_Client_Subsys     IN     VARCHAR2,
                                p_Offset            IN     NUMBER,
                                p_Limit             IN     NUMBER,
                                p_Total_Size           OUT NUMBER,
                                p_Portion_Content      OUT BLOB)
    IS
        l_Uf_Content   BLOB;
        l_Buffer       RAW (32767);
        l_Amount       NUMBER;
        l_Offset       NUMBER;
        l_Is_Allowed   NUMBER;
    --l_Content    BLOB;
    BEGIN
        --Перевіряємо наявність доступу до файлу для підсистеми запитувача
        SELECT SIGN (COUNT (*))
          INTO l_Is_Allowed
          FROM Uxp_Request  r
               JOIN Uss_Ndi.v_Ndi_Uxp_Access a ON r.Ur_Urt = a.Nua_Urt
               JOIN Uss_Ndi.v_Ndi_Uxp_Members m
                   ON     a.Nua_Um = m.Um_Id
                      AND m.Um_Code = p_Client_Code
                      AND m.Um_Subsys = p_Client_Subsys
         WHERE r.Ur_Id = p_Ur_Id;

        IF l_Is_Allowed <> 1
        THEN
            Raise_Application_Error (-20001, 'Доступ заборонено');
        END IF;

        BEGIN
            SELECT f.Uf_Content, f.Uf_Size
              INTO l_Uf_Content, p_Total_Size
              FROM Uxp_Files f
             WHERE f.Uf_Ur = p_Ur_Id;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                p_Total_Size := 0;
                RETURN;
        END;

        DBMS_LOB.Createtemporary (p_Portion_Content, TRUE);

        l_Offset := p_Offset;
        l_Amount := LEAST (p_Limit, 32767);

        BEGIN
            WHILE l_Amount > 0
            LOOP
                DBMS_LOB.Read (Lob_Loc   => l_Uf_Content,
                               Amount    => l_Amount,
                               Offset    => l_Offset,
                               Buffer    => l_Buffer);
                DBMS_LOB.Writeappend (Lob_Loc   => p_Portion_Content,
                                      Amount    => LENGTH (l_Buffer) / 2,
                                      Buffer    => l_Buffer);

                l_Offset := l_Offset + LENGTH (l_Buffer) / 2;
                l_Amount :=
                    LEAST (p_Limit - DBMS_LOB.Getlength (p_Portion_Content),
                           32767);
            END LOOP;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                NULL;
        END;
    -- p_Portion_Content := l_Content;
    END;

    PROCEDURE Build_And_Zip_Csv (p_Uf_Id        IN NUMBER,
                                 p_Csv_Header   IN VARCHAR2,
                                 p_Csv_Data     IN SYS_REFCURSOR)
    IS
        l_File                  BLOB;
        l_Ziped_File            BLOB;
        l_Chardata              VARCHAR2 (4000);
        l_Rawdata               RAW (32767);
        l_Datalength            BINARY_INTEGER := 32767;
        c_Line_Break   CONSTANT CHAR (2) := CHR (13) || CHR (10);
    BEGIN
        DBMS_LOB.Createtemporary (l_File, TRUE);
        --Додаємо в BLOB CSV заголовок
        l_Rawdata :=
            UTL_RAW.Cast_To_Raw (TRIM (p_Csv_Header) || c_Line_Break);
        l_Datalength := LENGTH (l_Rawdata) / 2;
        DBMS_LOB.Writeappend (l_File, l_Datalength, l_Rawdata);

        LOOP
            FETCH p_Csv_Data INTO l_Chardata;

            EXIT WHEN p_Csv_Data%NOTFOUND;

            l_Chardata := TRIM (l_Chardata || c_Line_Break);
            l_Rawdata := UTL_RAW.Cast_To_Raw (l_Chardata);
            l_Datalength := LENGTH (l_Rawdata) / 2;
            DBMS_LOB.Writeappend (l_File, l_Datalength, l_Rawdata);
        END LOOP;

        l_Ziped_File := UTL_COMPRESS.Lz_Compress (Src => l_File, Quality => 8);

        Set_File_Content (p_Uf_Id => p_Uf_Id, p_Uf_Content => l_Ziped_File);
    END;

    PROCEDURE Save_Json_Array (
        p_Ur_Id             IN            NUMBER,
        p_Json_Array        IN OUT NOCOPY CLOB,
        p_Compression_Lvl   IN            NUMBER DEFAULT NULL)
    IS
        l_Content   BLOB;
    BEGIN
        p_Json_Array := '[' || LTRIM (p_Json_Array, ',') || ']';
        l_Content := Tools.Convertc2butf8 (p_Json_Array);

        IF p_Compression_Lvl IS NOT NULL
        THEN
            l_Content :=
                UTL_COMPRESS.Lz_Compress (Src       => l_Content,
                                          Quality   => p_Compression_Lvl);
        END IF;

        INSERT INTO Uxp_Files (Uf_Id,
                               Uf_Ur,
                               Uf_Size,
                               Uf_Content,
                               Uf_Build_Dt)
             VALUES (0,
                     p_Ur_Id,
                     DBMS_LOB.Getlength (l_Content),
                     l_Content,
                     SYSDATE);
    END;

    /*
    info:    Отримання ідентифікатору файла по запиту
    author:  sho
    */
    FUNCTION Get_Ur_Uf (p_Ur_Id IN NUMBER)
        RETURN NUMBER
    IS
        l_Result   NUMBER;
    BEGIN
        SELECT f.Uf_Id
          INTO l_Result
          FROM Uxp_Files f
         WHERE f.Uf_Ur = p_Ur_Id;

        RETURN l_Result;
    END;

    /*
    info:    Перевірка доступу до забору відповіді на запит
    author:  sho
    request: #106637
    */
    FUNCTION Is_Allowed (p_Ur_Id IN NUMBER)
        RETURN BOOLEAN
    IS
        l_Is_Allowed   NUMBER;
    BEGIN
        SELECT SIGN (COUNT (*))
          INTO l_Is_Allowed
          FROM Uxp_Request  r
               JOIN Uss_Ndi.v_Ndi_Uxp_Access a ON r.Ur_Urt = a.Nua_Urt
               JOIN Uss_Ndi.v_Ndi_Uxp_Members m
                   ON     a.Nua_Um = m.Um_Id
                      AND m.Um_Code = Dnet$uxp_Request.g_Client_Member_Code
                      AND m.Um_Subsys = Dnet$uxp_Request.g_Client_Subsys
         WHERE r.Ur_Id = p_Ur_Id;

        RETURN l_Is_Allowed = 1;
    END;

    /*
    info:    Отримання відповіді по дельті
    author:  sho
    request: #106637
    note:
    */
    FUNCTION Get_Delta_Answer (p_Request_Id     IN NUMBER,            --Ignore
                               p_Request_Body   IN CLOB)
        RETURN CLOB
    IS
        l_Ur_Id                               NUMBER;
        l_Ubq_St                              VARCHAR2 (10);
        l_File_List                           XMLTYPE;
        l_File_Count                          NUMBER;

        c_Answer_Code_In_Process     CONSTANT NUMBER := 0;
        c_Answer_Code_Ready          CONSTANT NUMBER := 1;
        c_Answer_Code_Error          CONSTANT NUMBER := 2;
        c_Answer_Code_Unauthorized   CONSTANT NUMBER := 3;
        c_Answer_Code_Empty          CONSTANT NUMBER := 4;

        FUNCTION Response (p_Answer_Code   IN VARCHAR2,
                           p_Answer_Text   IN VARCHAR2,
                           p_Files_List    IN XMLTYPE DEFAULT NULL)
            RETURN CLOB
        IS
            l_Response   XMLTYPE;
        BEGIN
            SELECT XMLELEMENT (
                       "DeltaAnswerResponse",
                       API$UXP_UNIV.Answer_Xml (p_Answer_Code, p_Answer_Text),
                       p_Files_List)
              INTO l_Response
              FROM DUAL;

            RETURN l_Response.Getclobval;
        END;
    BEGIN
          SELECT Ur_Id
            INTO l_Ur_Id
            FROM XMLTABLE ('/*'
                           PASSING Xmltype (p_Request_Body)
                           COLUMNS Ur_Id    NUMBER PATH 'UrId');

        IF NOT Is_Allowed (l_Ur_Id)
        THEN
            RETURN Response (c_Answer_Code_Unauthorized, 'Доступ заборонено');
        END IF;

        --Визначаємо статус задачі по формуванню відповідей
        SELECT b.Ubq_St
          INTO l_Ubq_St
          FROM Uxp_Background_Queue b
         WHERE b.Ubq_Ur = l_Ur_Id;

        --Запит в обробці
        IF l_Ubq_St = Api$background.c_Ubq_St_Reg
        THEN
            RETURN Response (c_Answer_Code_In_Process,
                             'Запит в процесі обробки, спробуйте пізніше');
        --Помилка обробки
        ELSIF l_Ubq_St = Api$background.c_Ubq_St_Error
        THEN
            RETURN Response (c_Answer_Code_Error, 'Помилка обробки запиту');
        --Сформовано відповідь
        ELSIF l_Ubq_St = Api$background.c_Ubq_St_Processed
        THEN
            SELECT XMLELEMENT (
                       "ResponseFiles",
                       XMLAGG (
                           XMLELEMENT ("ResponseFile",
                                       XMLELEMENT ("FileId", f.Uf_Id),
                                       XMLELEMENT ("Size", f.Uf_Size)))),
                   COUNT (*)
              INTO l_File_List, l_File_Count
              FROM Uxp_Files f
             WHERE f.Uf_Ur = l_Ur_Id;

            IF l_File_Count = 0
            THEN
                RETURN Response (
                           c_Answer_Code_Empty,
                           'За наданими параметрами запиту даних не знайдено');
            END IF;

            RETURN Response (c_Answer_Code_Ready,
                             'Відповідь сформовано',
                             l_File_List);
        END IF;
    END;

    /*
    info:    Отримання файлу відповіді по дельті
    author:  sho
    request: #106637
    note:
    */
    FUNCTION Get_Delta_Answer_File (p_Request_Id     IN NUMBER,       --Ignore
                                    p_Request_Body   IN CLOB)
        RETURN CLOB
    IS
        l_Uf_Id                               NUMBER;
        l_Ur_Id                               NUMBER;
        l_Content                             BLOB;

        c_Answer_Code_Ok             CONSTANT NUMBER := 1;
        c_Answer_Code_Unauthorized   CONSTANT NUMBER := 3;

        FUNCTION Response (p_Answer_Code   IN VARCHAR2,
                           p_Answer_Text   IN VARCHAR2,
                           p_Content       IN BLOB DEFAULT NULL)
            RETURN CLOB
        IS
            l_Response   XMLTYPE;
        BEGIN
            SELECT XMLELEMENT (
                       "DeltaFileResponse",
                       API$UXP_UNIV.Answer_Xml (p_Answer_Code, p_Answer_Text),
                       CASE
                           WHEN p_Content IS NOT NULL
                           THEN
                               XMLELEMENT (
                                   "Content",
                                   Tools.Convertblobtobase64 (p_Content))
                       END)
              INTO l_Response
              FROM DUAL;

            RETURN l_Response.Getclobval;
        END;
    BEGIN
            SELECT File_Id
              INTO l_Uf_Id
              FROM XMLTABLE ('/*'
                             PASSING Xmltype (p_Request_Body)
                             COLUMNS File_Id    NUMBER PATH 'FileId');

        SELECT f.Uf_Ur
          INTO l_Ur_Id
          FROM Uxp_Files f
         WHERE f.Uf_Id = l_Uf_Id;

        IF NOT Is_Allowed (l_Ur_Id)
        THEN
            RETURN Response (c_Answer_Code_Unauthorized, 'Доступ заборонено');
        END IF;

        SELECT f.Uf_Content
          INTO l_Content
          FROM Uxp_Files f
         WHERE f.Uf_Id = l_Uf_Id;

        RETURN Response (c_Answer_Code_Ok, 'Відповідь надано', l_Content);
    END;
END Api$uxp_Files;
/