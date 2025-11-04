/* Formatted on 8/12/2025 6:10:00 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYS.REPL_CONTROLL
IS
    -- Author  : MAXYM
    -- Created : 08.09.2003 10:13:53
    -- Purpose : Управление объектами репликатора

    -- Добавляет новый узел с кодом p_nodecode
    -- Указать в p_islocal является ли он локальным или удаленым
    PROCEDURE AddNode (p_nodecode VARCHAR2, p_islocal BOOLEAN);

    -- Удаляет узел с кодом p_nodecode и все связанные сним контролеры и параметры
    -- Для широковещательных контроллеров удаляется только привязка
    -- Если объекта нет - исключение НЕ появляется
    PROCEDURE DeleteNode (p_nodecode VARCHAR2);

    -- Возвращает идентификатор узла с кодом p_nodecode в таблице rp_subscr
    -- Если такой узел не зарегестрирован - возвратит NULL
    FUNCTION GetNodeID (p_nodecode VARCHAR2)
        RETURN NUMBER;

    -- Добавляет контролер с именем p_controller_name для шаблона p_template_name
    -- Если шаблон не найден выдает исключение
    -- Если известно что контролер будет привязан только к одному узлу
    -- Используйте для имени p_template_name||'_'||<Код узла привязки>
    PROCEDURE AddController (p_template_name     VARCHAR2,
                             p_controller_name   VARCHAR2);

    -- Удаляет контролер с именем p_controller_name
    -- Если объекта нет - исключение НЕ появляется
    PROCEDURE DeleteController (p_controller_name VARCHAR2);

    -- Выдает идентификатор контролера с именем p_controller_name
    -- Если контролер не найден выдает NULL
    FUNCTION GetControllerID (p_controller_name VARCHAR2)
        RETURN NUMBER;

    -- Добовляет привязку контролера с именем p_controller_name к узлу с именем p_nodecode в который нужно отгружать данные
    -- При непсуществующих объектах с такими именами генерится исключение
    PROCEDURE AddLinkToController (p_controller_name   VARCHAR2,
                                   p_nodecode          VARCHAR2);

    -- Удаляет привязку контролера с именем p_controller_name к узлу с именем p_nodecode
    -- При непсуществующих объектах с такими именами генерится исключение
    PROCEDURE DeleteLinkFromController (p_controller_name   VARCHAR2,
                                        p_nodecode          VARCHAR2);

    --  Добавить расписание для контроллера с именем p_controller_name
    --  p_nexttime - когда запускать в следующий раз. Если необходимо стартовать немедленно проставить sysdate
    --  p_sec_interval - с какой периодичностью запускать. Если единоразовый запуск - проставить NULL
    -- При непсуществующих объектах с такими именами генерится исключение
    PROCEDURE AddScheduleForController (p_controller_name   VARCHAR2,
                                        p_nexttime          DATE,
                                        p_sec_interval      NUMBER);

    --  Очистить список расписаний для контроллера с именем p_controller_name
    -- При непсуществующих объектах с такими именами генерится исключение
    PROCEDURE ClearControllerScedules (p_controller_name VARCHAR2);
END REPL_CONTROLL;
/


/* Formatted on 8/12/2025 6:10:05 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_SYS.REPL_CONTROLL
IS
    --------
    PROCEDURE AddNode (p_nodecode VARCHAR2, p_islocal BOOLEAN)
    IS
        max_id   rp_subscr.rp_subscr_id%TYPE;
    BEGIN
        -- Вычисляем новый идентификатор
        SELECT MAX (rp_subscr_id) INTO max_id FROM rp_subscr;

        IF max_id IS NULL
        THEN
            max_id := 1;
        ELSE
            max_id := max_id + 1;
        END IF;

        -- вставка значения, для локального переводим предыдущий "локальный" в состояние "доступный"
        IF p_islocal
        THEN
            UPDATE rp_subscr
               SET rp_subscr_type = 'enabled'
             WHERE rp_subscr_type = 'local';

            INSERT INTO rp_subscr (rp_subscr_id,
                                   rp_subscr_dbid,
                                   rp_subscr_type)
                 VALUES (max_id, p_nodecode, 'local');
        ELSE
            INSERT INTO rp_subscr (rp_subscr_id,
                                   rp_subscr_dbid,
                                   rp_subscr_type)
                 VALUES (max_id, p_nodecode, 'enabled');
        END IF;
    END;

    --------
    PROCEDURE DeleteNode (p_nodecode VARCHAR2)
    IS
        NodeID   rp_subscr.rp_subscr_id%TYPE;
    BEGIN
        NodeID := GetNodeID (p_nodecode);

        IF NOT NodeID IS NULL
        THEN
            -- Удаляем завязанные на узел не широковещательные контролеры
            DELETE FROM rp_sc_controllers
                  WHERE     EXISTS
                                (SELECT 1
                                   FROM rp_link_scc_subscr
                                  WHERE     rp_lssu_scc_id = rp_scc_id
                                        AND rp_lssu_subscr_id = NodeID)
                        AND NOT EXISTS
                                (SELECT 1
                                   FROM rp_link_scc_subscr
                                  WHERE     rp_lssu_scc_id = rp_scc_id
                                        AND rp_lssu_subscr_id <> NodeID);

            -- Удаляем ссылки в широковещательных
            DELETE FROM rp_link_scc_subscr
                  WHERE rp_lssu_subscr_id = NodeID;

            --  Удаляем параметры узла
            DELETE FROM dbid_params
                  WHERE UPPER (param_dbid) = UPPER (p_nodecode);

            -- Удаляем узел
            DELETE FROM rp_subscr
                  WHERE rp_subscr_id = NodeID;
        END IF;
    END;

    --------
    FUNCTION GetNodeID (p_nodecode VARCHAR2)
        RETURN NUMBER
    IS
        NodeID   rp_subscr.rp_subscr_id%TYPE;
    BEGIN
        SELECT MAX (rp_subscr_id)
          INTO NodeID
          FROM rp_subscr
         WHERE UPPER (rp_subscr_dbid) = UPPER (p_nodecode);

        RETURN NodeID;
    END;

    --------
    FUNCTION GetTemplateID (p_templ_code VARCHAR2)
        RETURN NUMBER
    IS
        templ_id   rp_sc_controllers.rp_scc_id%TYPE;
    BEGIN
        SELECT MAX (rp_scc_id)
          INTO templ_id
          FROM rp_sc_controllers
         WHERE     UPPER (rp_scc_name) = UPPER (p_templ_code)
               AND rp_scc_status = 2;

        RETURN templ_id;
    END;

    --------
    PROCEDURE AddController (p_template_name     VARCHAR2,
                             p_controller_name   VARCHAR2)
    IS
        templ_id   rp_sc_controllers.rp_scc_id%TYPE;
        max_id     rp_sc_controllers.rp_scc_id%TYPE;
    BEGIN
        templ_id := Gettemplateid (p_template_name);

        IF templ_id IS NULL
        THEN
            Raise_application_error (
                -20000,
                'Template does not exists. ' || p_template_name);
        END IF;

        -- Вычисляем новый идентификатор с учетом диапазона пользовательских контролеров
        SELECT MAX (rp_scc_id) INTO max_id FROM rp_sc_controllers;

        IF (max_id IS NULL) OR (max_id < 10000001)
        THEN
            max_id := 10000001;
        ELSE
            max_id := max_id + 1;
        END IF;

        -- Вставка контролера
        INSERT INTO rp_sc_controllers (rp_scc_id,
                                       rp_scc_name,
                                       rp_scc_master,
                                       rp_scc_description,
                                       rp_scc_status)
            (SELECT max_id,
                    p_controller_name,
                    rp_scc_id,
                    rp_scc_description,
                    1
               FROM rp_sc_controllers
              WHERE rp_scc_id = templ_id);
    END;

    --------
    PROCEDURE DeleteController (p_controller_name VARCHAR2)
    IS
    BEGIN
        DELETE FROM rp_sc_controllers
              WHERE UPPER (rp_scc_name) = UPPER (p_controller_name);
    END;

    --------
    FUNCTION GetControllerID (p_controller_name VARCHAR2)
        RETURN NUMBER
    IS
        templ_id   rp_sc_controllers.rp_scc_id%TYPE;
    BEGIN
        SELECT MAX (rp_scc_id)
          INTO templ_id
          FROM rp_sc_controllers
         WHERE     UPPER (rp_scc_name) = UPPER (p_controller_name)
               AND rp_scc_status = 1;

        RETURN templ_id;
    END;

    --------
    PROCEDURE DeleteLinkFromController (p_controller_name   VARCHAR2,
                                        p_nodecode          VARCHAR2)
    IS
        templ_id   rp_sc_controllers.rp_scc_id%TYPE;
        node_id    rp_subscr.rp_subscr_id%TYPE;
    BEGIN
        templ_id := Getcontrollerid (p_controller_name);

        IF templ_id IS NULL
        THEN
            Raise_application_error (
                -20000,
                'Controller does not exists. ' || p_controller_name);
        END IF;

        node_id := GetNodeId (p_nodecode);

        IF node_id IS NULL
        THEN
            Raise_application_error (-20000,
                                     'Node does not exists. ' || p_nodecode);
        END IF;

        -- Удаление привязки
        DELETE FROM rp_link_scc_subscr
              WHERE rp_lssu_scc_id = templ_id AND rp_lssu_subscr_id = node_id;
    END;

    --------
    PROCEDURE AddLinkToController (p_controller_name   VARCHAR2,
                                   p_nodecode          VARCHAR2)
    IS
        templ_id   rp_sc_controllers.rp_scc_id%TYPE;
        node_id    rp_subscr.rp_subscr_id%TYPE;
    BEGIN
        DeleteLinkFromController (p_controller_name, p_nodecode);

        templ_id := Getcontrollerid (p_controller_name);

        IF templ_id IS NULL
        THEN
            Raise_application_error (
                -20000,
                'Controller does not exists. ' || p_controller_name);
        END IF;

        node_id := GetNodeId (p_nodecode);

        IF node_id IS NULL
        THEN
            Raise_application_error (-20000,
                                     'Node does not exists. ' || p_nodecode);
        END IF;

        -- Привязка контролера к узлу
        INSERT INTO rp_link_scc_subscr (rp_lssu_scc_id, rp_lssu_subscr_id)
             VALUES (templ_id, node_id);
    END;

    --------
    PROCEDURE AddScheduleForController (p_controller_name   VARCHAR2,
                                        p_nexttime          DATE,
                                        p_sec_interval      NUMBER)
    IS
        controller_id   rp_sc_controllers.rp_scc_id%TYPE;
        max_id          rp_scheduler.rp_sch_id%TYPE;
    BEGIN
        -- Получаем контроллер
        controller_id := GetControllerID (p_controller_name);

        IF controller_id IS NULL
        THEN
            Raise_application_error (
                -20000,
                'Controller does not exists. ' || p_controller_name);
        END IF;

        -- Вычисляем идентификатор
        SELECT MAX (rp_sch_id) INTO max_id FROM rp_scheduler;

        IF max_id IS NULL
        THEN
            max_id := 1;
        ELSE
            max_id := max_id + 1;
        END IF;

        -- Вставляем
        INSERT INTO rp_scheduler (rp_sch_id,
                                  rp_sch_nexttime,
                                  rp_sch_interval,
                                  rp_sch_enabled,
                                  rp_sch_scc)
             VALUES (max_id,
                     p_nexttime,
                     p_sec_interval,
                     1,
                     controller_id);
    END;

    --------
    PROCEDURE ClearControllerScedules (p_controller_name VARCHAR2)
    IS
        controller_id   rp_sc_controllers.rp_scc_id%TYPE;
    BEGIN
        -- Вычисляем контролер
        controller_id := GetControllerID (p_controller_name);

        IF controller_id IS NULL
        THEN
            Raise_application_error (
                -20000,
                'Controller does not exists. ' || p_controller_name);
        END IF;

        -- Удаляем
        DELETE FROM rp_scheduler
              WHERE rp_sch_scc = controller_id;
    END;
END REPL_CONTROLL;
/