/* Formatted on 8/12/2025 6:10:43 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_RBM.API$BACKGROUND
IS
    -- Author  : SHOSTAK
    -- Created : 02.04.2024 9:53:33 AM
    -- Purpose : Фонова обробка запитів/відповідей

    --------------------------------------------------------------------------
    --Константи
    --------------------------------------------------------------------------
    --Статуси фонових завдань
    c_Ubq_St_Reg         CONSTANT VARCHAR2 (10) := 'R';        --Зареєстровано
    c_Ubq_St_Processed   CONSTANT VARCHAR2 (10) := 'P';            --Оброблено
    c_Ubq_St_Error       CONSTANT VARCHAR2 (10) := 'E';      --Помилка обробки

    /*
    info:    Реєстрація фонової задачі на відпрацювання відповіді на вихідний запит
    author:  sho
    request: #92776
    note:    Деталі в описі до Register_Background
    */
    PROCEDURE Register_Background (
        p_Ur_Id         Uxp_Request.Ur_Id%TYPE,                    --Ід запиту
        p_Ubq_Content   Uxp_Background_Queue.Ubq_Content%TYPE --Вміст відповіді
                                                             );

    /*
    info:    Обробка черги завдань.
    author:  sho
    request: #92776
    note:    Параметри p_Queue та p_Job потрібні для того, щоб розпаралелити обробку.
    Під кожну чергу буде створено окремий джоб, який буде передавати певний тип черги в p_Queue
    Номер джоба(p_Job) потрібен для того, що можна було додатково розпаралелити обробку в рамках однієї черги.
    */
    PROCEDURE Handle_Queue (p_Job IN NUMBER DEFAULT 1 --Номер джоба що виконує обробку
                                                     );

    /*
    info:    Базовий обробник відповіді на вихідний запит, що реєструє задачу для фонового відпрацювання
    author:  sho
    request: #92776
    note:    Цю процедуру можна прописувати в Uxp_Req_Types.Urt_Work_Func
    у разі, якщо потрібно обробити відповідь фоново.
    Хоча це не обов'язково, бо в деяких випадках може бути потреба
    виконати попередню обробку відповіді і прийняти рішення про необхідність
    постановки в чергу для фонової оброки. Якщо є така потреба, то замість
    цієї процедури в Uxp_Req_Types.Urt_Work_Func прописується прикладна процедура
    обробки відповіді
    */
    PROCEDURE Handle_Out (p_Ur_Id      IN     NUMBER,
                          p_Response   IN     CLOB,
                          p_Error      IN OUT VARCHAR2);

    /*
    info:    Базовий обробник відповіді на вихідний запит, що реєструє задачу для фонового відпрацювання
    author:  sho
    request: #92776
    note:    Цю процедуру можна прописувати в Uxp_Req_Types.Urt_Work_Func
    у разі, якщо потрібно обробити запит фоново.
    Хоча це не обов'язково, бо в деяких випадках може бути потреба
    виконати попередню обробку запиту і прийняти рішення про необхідність
    постановки в чергу для фонової оброки. Якщо є така потреба, то замість
    цієї процедури в Uxp_Req_Types.Urt_Work_Func прописується прикладна процедура
    обробки запиту
    */
    FUNCTION Handle_In (p_Request_Id IN NUMBER, p_Request_Body IN CLOB)
        RETURN CLOB;
END Api$background;
/


GRANT EXECUTE ON IKIS_RBM.API$BACKGROUND TO SERVICE_PROXY
/

GRANT EXECUTE ON IKIS_RBM.API$BACKGROUND TO USS_ESR
/

GRANT EXECUTE ON IKIS_RBM.API$BACKGROUND TO USS_PERSON
/

GRANT EXECUTE ON IKIS_RBM.API$BACKGROUND TO USS_RNSP
/

GRANT EXECUTE ON IKIS_RBM.API$BACKGROUND TO USS_VISIT
/


/* Formatted on 8/12/2025 6:10:45 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_RBM.API$BACKGROUND
IS
    /*
    info:    Реєстрація фонової задачі на відпрацювання запиту або відповіді
    author:  sho
    request: #92776
    note:    Використовується у разі, якщо вхідний запит або відповідь на вихідний запит,
    які потрібно обробити містять багато даних, час обробки яких потенційно займе більше 10 сек.
    Це потрібно для того, щоб не тримати одночасно велику кількість відкритих сесій в сервісах обробки запитів
    І виконувати обробку фоново.

    Для можливості фонової обробки потрібно в Uxp_Req_Types.Urt_Background_Func прописати процедуру, що буде цю обробку виконувати
    Процедура повинна містити параметри: p_Uro_Id IN NUMBER, p_Response IN CLOB.
    Також в Uxp_Req_Types.Urt_Background_Job потрібно вказати номер джоба в якому буде виконуватись обробка.
    Якщо не потрібно додатково розпаралелювати обробку в рамках однієї черги, вказуйте 1
    */
    PROCEDURE Register_Background (
        p_Ubq_Urt       Uxp_Background_Queue.Ubq_Urt%TYPE, --Тип запиту(Uxp_Req_Types.Urt_Id) в якій потрапить цей рядок.
        p_Ubq_Ur        Uxp_Background_Queue.Ubq_Ur%TYPE,          --Ід запиту
        p_Ubq_Content   Uxp_Background_Queue.Ubq_Content%TYPE --Вміст запиту/відповіді
                                                             )
    IS
    BEGIN
        INSERT INTO Uxp_Background_Queue (Ubq_Id,
                                          Ubq_Ur,
                                          Ubq_Content,
                                          Ubq_St,
                                          Ubq_Urt,
                                          Ubq_Create_Dt)
             VALUES (0,
                     p_Ubq_Ur,
                     p_Ubq_Content,
                     c_Ubq_St_Reg,
                     p_Ubq_Urt,
                     SYSDATE);
    END;

    /*
    info:    Реєстрація фонової задачі на відпрацювання відповіді на вихідний запит
    author:  sho
    request: #92776
    note:    Деталі в описі до Register_Background
    */
    PROCEDURE Register_Background (
        p_Ur_Id         Uxp_Request.Ur_Id%TYPE,                    --Ід запиту
        p_Ubq_Content   Uxp_Background_Queue.Ubq_Content%TYPE --Вміст відповіді
                                                             )
    IS
        l_Urt_Id   NUMBER;
    BEGIN
        SELECT r.Ur_Urt
          INTO l_Urt_Id
          FROM Uxp_Request r
         WHERE r.Ur_Id = p_Ur_Id;

        Register_Background (p_Ubq_Urt       => l_Urt_Id,
                             p_Ubq_Ur        => p_Ur_Id,
                             p_Ubq_Content   => p_Ubq_Content);
    END;

    /*
    info:    Зміна стану фонової задачі
    author:  sho
    request: #92776
    */
    PROCEDURE Set_Ubq_St (
        p_Ubq_Id            Uxp_Background_Queue.Ubq_Id%TYPE,      --Ід задачі
        p_Ubq_St            Uxp_Background_Queue.Ubq_St%TYPE,           --Стан
        p_Ubq_Error         Uxp_Background_Queue.Ubq_Error%TYPE DEFAULT NULL, --Інформація про помилу
        p_Handle_Start_Dt   DATE --Дата почтку обробки задачі(потрібно щоб розрахувати витрачений час на обробку)
                                )
    IS
    BEGIN
        UPDATE Uxp_Background_Queue q
           SET q.Ubq_St = p_Ubq_St,
               q.Ubq_Handle_Dt = SYSDATE,
               q.Ubq_Handle_Time =
                   (SYSDATE - p_Handle_Start_Dt) * 24 * 60 * 60,
               q.Ubq_Error = p_Ubq_Error
         WHERE q.Ubq_Id = p_Ubq_Id;
    END;

    /*
    info:    Зміна стану задачі на "Оброблено"
    author:  sho
    request: #92776
    */
    PROCEDURE Set_Processed (p_Ubq_Id            Uxp_Background_Queue.Ubq_Id%TYPE, --Ід задачі
                             p_Handle_Start_Dt   DATE --Дата почтку обробки задачі(потрібно щоб розрахувати витрачений час на обробку)
                                                     )
    IS
    BEGIN
        Set_Ubq_St (p_Ubq_Id            => p_Ubq_Id,
                    p_Ubq_St            => c_Ubq_St_Processed,
                    p_Handle_Start_Dt   => p_Handle_Start_Dt);
    END;

    /*
    info:    Зміна стану задачі на "Помилка"
    author:  sho
    request: #92776
    */
    PROCEDURE Set_Error (p_Ubq_Id            Uxp_Background_Queue.Ubq_Id%TYPE, --Ід задачі
                         p_Ubq_Error         Uxp_Background_Queue.Ubq_Error%TYPE, --Інформація про помилу
                         p_Handle_Start_Dt   DATE --Дата почтку обробки задачі(потрібно щоб розрахувати витрачений час на обробку)
                                                 )
    IS
    BEGIN
        Set_Ubq_St (p_Ubq_Id            => p_Ubq_Id,
                    p_Ubq_St            => c_Ubq_St_Error,
                    p_Ubq_Error         => p_Ubq_Error,
                    p_Handle_Start_Dt   => p_Handle_Start_Dt);
    END;

    /*
    info:    Обробка черги завдань.
    author:  sho
    request: #92776
    note:    Параметри p_Queue та p_Job потрібні для того, щоб розпаралелити обробку.
    Під кожну чергу буде створено окремий джоб, який буде передавати певний тип черги в p_Queue
    Номер джоба(p_Job) потрібен для того, що можна було додатково розпаралелити обробку в рамках однієї черги.
    */
    PROCEDURE Handle_Queue (p_Job IN NUMBER DEFAULT 1 --Номер джоба що виконує обробку
                                                     )
    IS
        l_Ack_Content   CLOB;
    BEGIN
        --Проходимось по всім задачам в статусі "Зареєстровано",
        --по вказаній черзі та номеру джоба
        FOR Rec
            IN (SELECT q.Ubq_Id,
                       q.Ubq_Ur,
                       q.Ubq_Content,
                       Tt.Nrt_Id,
                       Tt.Nrt_Direction,
                       Tt.Nrt_Ack_Nrt,
                       Tt.Nrt_Background_Func
                  FROM Uxp_Background_Queue  q
                       JOIN Uss_Ndi.v_Ndi_Uxp_Req_Types t
                           ON q.Ubq_Urt = t.Urt_Id
                       JOIN Uss_Ndi.v_Ndi_Request_Type Tt
                           ON t.Urt_Nrt = Tt.Nrt_Id
                 WHERE     q.Ubq_St = c_Ubq_St_Reg
                       AND Tt.Nrt_Background_Job = p_Job)
        LOOP
            DECLARE
                l_Handle_Start_Dt   DATE;
                l_Ack_Ur            NUMBER;
                l_Ack_Rn            NUMBER;
            BEGIN
                --Фіксуємо час початку обробки завдання
                l_Handle_Start_Dt := SYSDATE;

                IF Rec.Nrt_Direction = 'OUT'
                THEN
                    --Обробка відповіді на вихідний запит
                    EXECUTE IMMEDIATE   'BEGIN '
                                     || Rec.Nrt_Background_Func
                                     || '(p_Ur_Id=>:p_Ur_Id, p_Response=>:p_Response); END;'
                        USING Rec.Ubq_Ur, Rec.Ubq_Content;
                ELSE
                    IF Rec.Nrt_Ack_Nrt IS NULL
                    THEN
                        --Обробка вхідного запиту
                        EXECUTE IMMEDIATE   'BEGIN '
                                         || Rec.Nrt_Background_Func
                                         || '(p_Ur_Id=>:p_Ur_Id, p_Request=>:p_Request); END;'
                            USING Rec.Ubq_Ur, Rec.Ubq_Content;
                    ELSE
                        --Обробка вхідного запиту та відправка квитанції у відповідь
                        EXECUTE IMMEDIATE   'BEGIN :p_Ack_Content :='
                                         || Rec.Nrt_Background_Func
                                         || '(p_Ur_Id=>:p_Ur_Id, p_Request=>:p_Request); END;'
                            USING OUT l_Ack_Content,
                                  IN Rec.Ubq_Ur,
                                  IN Rec.Ubq_Content;

                        Api$uxp_Request.Register_Out_Request (
                            p_Ur_Plan_Dt     => SYSDATE,
                            p_Ur_Urt         => NULL,
                            p_Ur_Create_Wu   => NULL,
                            p_Ur_Ext_Id      => NULL,
                            p_Ur_Body        => l_Ack_Content,
                            p_New_Id         => l_Ack_Ur,
                            p_Rn_Nrt         => Rec.Nrt_Ack_Nrt,
                            p_Rn_Src         => NULL,
                            p_Rn_Hs_Ins      => Tools.Gethistsession,
                            p_New_Rn_Id      => l_Ack_Rn);

                        --Зберігаємо зв'язок між вхідним запитом та запитом з квитанцією
                        INSERT INTO Uxp_Ack (Ua_Id, Ua_Ur_In, Ua_Ur_Out)
                             VALUES (0, Rec.Ubq_Ur, l_Ack_Ur);
                    END IF;
                END IF;

                --Змінюємо стан завдання на "Оброблено"
                Set_Processed (p_Ubq_Id            => Rec.Ubq_Id,
                               p_Handle_Start_Dt   => l_Handle_Start_Dt);
            EXCEPTION
                WHEN OTHERS
                THEN
                    --Змінюємо стан завдання на "Помилка"
                    Set_Error (
                        p_Ubq_Id            => Rec.Ubq_Id,
                        p_Handle_Start_Dt   => l_Handle_Start_Dt,
                        p_Ubq_Error         =>
                               SQLERRM
                            || CHR (10)
                            || DBMS_UTILITY.Format_Error_Stack
                            || DBMS_UTILITY.Format_Error_Backtrace);
            END;

            COMMIT;
        END LOOP;
    END;

    /*
    info:    Базовий обробник відповіді на вихідний запит, що реєструє задачу для фонового відпрацювання
    author:  sho
    request: #92776
    note:    Цю процедуру можна прописувати в Uxp_Req_Types.Urt_Work_Func
    у разі, якщо потрібно обробити відповідь фоново.
    Хоча це не обов'язково, бо в деяких випадках може бути потреба
    виконати попередню обробку відповіді і прийняти рішення про необхідність
    постановки в чергу для фонової оброки. Якщо є така потреба, то замість
    цієї процедури в Uxp_Req_Types.Urt_Work_Func прописується прикладна процедура
    обробки відповіді
    */
    PROCEDURE Handle_Out (p_Ur_Id      IN     NUMBER,
                          p_Response   IN     CLOB,
                          p_Error      IN OUT VARCHAR2)
    IS
    BEGIN
        IF p_Error IS NOT NULL
        THEN
            Api$uxp_Request.Delay_Request_Exception (
                p_Ur_Id           => p_Ur_Id,
                p_Delay_Seconds   => 300,
                p_Delay_Reason    => p_Error);
        END IF;

        Register_Background (p_Ur_Id => p_Ur_Id, p_Ubq_Content => p_Response);
    END;

    /*
    info:    Базовий обробник відповіді на вихідний запит, що реєструє задачу для фонового відпрацювання
    author:  sho
    request: #92776
    note:    Цю процедуру можна прописувати в Uxp_Req_Types.Urt_Work_Func
    у разі, якщо потрібно обробити запит фоново.
    Хоча це не обов'язково, бо в деяких випадках може бути потреба
    виконати попередню обробку запиту і прийняти рішення про необхідність
    постановки в чергу для фонової оброки. Якщо є така потреба, то замість
    цієї процедури в Uxp_Req_Types.Urt_Work_Func прописується прикладна процедура
    обробки запиту
    */
    FUNCTION Handle_In (p_Request_Id IN NUMBER, p_Request_Body IN CLOB)
        RETURN CLOB
    IS
    BEGIN
        Register_Background (p_Ur_Id         => p_Request_Id,
                             p_Ubq_Content   => p_Request_Body);

        RETURN NULL;
    END;
END Api$background;
/