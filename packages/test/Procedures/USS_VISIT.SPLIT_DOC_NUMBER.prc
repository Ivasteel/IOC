/* Formatted on 8/12/2025 6:00:14 PM (QP5 v5.417) */
CREATE OR REPLACE PROCEDURE USS_VISIT.Split_Doc_Number (
    p_Ndt_Id       IN     NUMBER,
    p_Doc_Number   IN OUT VARCHAR2,
    p_Doc_Serial      OUT VARCHAR2)
IS
BEGIN
    IF p_Ndt_Id = 37                                --свідоцтво про народження
    THEN
        --#73812
        p_Doc_Serial := SUBSTR (p_Doc_Number, 1, LENGTH (p_Doc_Number) - 6);
        p_Doc_Number := SUBSTR (p_Doc_Number, LENGTH (p_Doc_Number) - 5, 6);
    ELSIF p_Ndt_Id = 10052                                       --Довідка ВПО
    THEN
        p_Doc_Serial :=
            REPLACE (p_Doc_Number,
                     REGEXP_REPLACE (p_Doc_Number, '[^0-9-]', ''));
        p_Doc_Number := REGEXP_REPLACE (p_Doc_Number, '[^0-9-]', '');
    ELSE
        --todo: враховувати тип документу, якщо серія може містити не тільки букви, або номер може містити не тільки цифри
        p_Doc_Serial :=
            REPLACE (p_Doc_Number,
                     REGEXP_REPLACE (p_Doc_Number, '[^0-9]', ''));
        p_Doc_Number := REGEXP_REPLACE (p_Doc_Number, '[^0-9]', '');
    END IF;
END Split_Doc_Number;
/
