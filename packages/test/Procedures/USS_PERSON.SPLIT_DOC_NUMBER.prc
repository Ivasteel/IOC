/* Formatted on 8/12/2025 5:57:20 PM (QP5 v5.417) */
CREATE OR REPLACE PROCEDURE USS_PERSON.Split_Doc_Number (
    p_Ndt_Id       IN     NUMBER,
    p_Doc_Number   IN OUT VARCHAR2,
    p_Doc_Serial      OUT VARCHAR2)
IS
BEGIN
    p_Doc_Number := UPPER (REPLACE (p_Doc_Number, ' ', ''));

    IF p_Ndt_Id = 6
    THEN
        p_Doc_Serial :=
            TRANSLATE (SUBSTR (p_Doc_Number, 1, LENGTH (p_Doc_Number) - 6),
                       'ABCIETOPHKXM',
                       '¿¬—≤≈“Œ–Õ ’Ã');
        p_Doc_Number := SUBSTR (p_Doc_Number, LENGTH (p_Doc_Number) - 5, 6);
    ELSIF p_Ndt_Id IN (37, 11)
    THEN
        p_Doc_Serial := SUBSTR (p_Doc_Number, 1, LENGTH (p_Doc_Number) - 6);
        p_Doc_Number := SUBSTR (p_Doc_Number, LENGTH (p_Doc_Number) - 5, 6);
    ELSIF p_Ndt_Id = 10052                                       --ƒÓ‚≥‰Í‡ ¬œŒ
    THEN
        p_Doc_Serial :=
            REPLACE (p_Doc_Number,
                     REGEXP_REPLACE (p_Doc_Number, '[^0-9-]', ''));
        p_Doc_Number := REGEXP_REPLACE (p_Doc_Number, '[^0-9-]', '');
    ELSE
        p_Doc_Serial := NULL;
        p_Doc_Number := p_Doc_Number;
    END IF;

    p_Doc_Serial := TRIM ('-' FROM p_Doc_Serial);
END Split_Doc_Number;
/
