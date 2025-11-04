/* Formatted on 8/12/2025 5:50:13 PM (QP5 v5.417) */
CREATE OR REPLACE FUNCTION USS_ESR.get_attr_str (p_doc_id   NUMBER,
                                                 p_nda_id   NUMBER)
    RETURN VARCHAR2
IS
    l_str   VARCHAR2 (4000);
BEGIN
    SELECT aa.apda_val_string
      INTO l_str
      FROM ap_document_attr aa
     WHERE aa.apda_apd = p_doc_id AND aa.apda_nda = p_nda_id;

    RETURN l_str;
EXCEPTION
    WHEN NO_DATA_FOUND
    THEN
        RETURN NULL;
END;
/
