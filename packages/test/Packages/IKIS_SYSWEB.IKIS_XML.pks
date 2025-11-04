/* Formatted on 8/12/2025 6:11:41 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYSWEB.IKIS_XML
IS
    -- Author  : IVANR
    -- Created : 18.08.2008 16:34:16
    -- Purpose :
    -- Пакет для работы с XML


    PROCEDURE GetRootNode (xmlString         IN     VARCHAR2,
                           XmlRootNode          OUT DBMS_XMLDOM.DOMNode,
                           XmlRootNodeName      OUT VARCHAR2);

    PROCEDURE GetChildNodes (XmlNode         IN     DBMS_XMLDOM.DOMNode,
                             XmlChildNodes      OUT DBMS_XMLDOM.DOMNodelist,
                             v_countNodes       OUT NUMBER);

    PROCEDURE GetNodesData (XmlNode            IN     DBMS_XMLDOM.DOMNode,
                            XmlNodeName           OUT VARCHAR2, -- навзвание узла
                            XmlNodeText           OUT VARCHAR2,  -- текст узла
                            XmlNodeAttribute      OUT XmlAtribute); -- атрибуты узла

    PROCEDURE GetNodeValue (XmlString   IN     VARCHAR2,
                            NodeName    IN     VARCHAR2,
                            NodeValue      OUT VARCHAR2);
END IKIS_XML;
/


CREATE OR REPLACE PUBLIC SYNONYM IKIS_XML FOR IKIS_SYSWEB.IKIS_XML
/


GRANT EXECUTE ON IKIS_SYSWEB.IKIS_XML TO II01RC_SYSWEB_COMM
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_XML TO IKIS_FINZVIT WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_XML TO IKIS_PERSON WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_XML TO IKIS_RBM WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_XML TO IKIS_WEBPROXY
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_XML TO USS_CEA WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_XML TO USS_DOC WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_XML TO USS_ESR WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_XML TO USS_EXCH WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_XML TO USS_NDI WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_XML TO USS_PERSON WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_XML TO USS_RNSP WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_XML TO USS_RPT WITH GRANT OPTION
/

GRANT EXECUTE ON IKIS_SYSWEB.IKIS_XML TO USS_VISIT WITH GRANT OPTION
/


/* Formatted on 8/12/2025 6:11:45 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_SYSWEB.IKIS_XML
IS
    --TYPE XmlAtribute IS RECORD (AttributeNfme varchar2(30), AttributeValue varchar2(30));
    PROCEDURE GetRootNode (xmlString         IN     VARCHAR2,
                           XmlRootNode          OUT DBMS_XMLDOM.DOMNode,
                           XmlRootNodeName      OUT VARCHAR2)
    IS
        l_parser   DBMS_XMLPARSER.Parser;
        l_xmldoc   DBMS_XMLDOM.DOMDocument;
        l_node     DBMS_XMLDOM.DOMNode;
        l_elem     xmldom.DOMElement;
    BEGIN
        l_parser := DBMS_XMLPARSER.newParser;
        DBMS_XMLPARSER.setValidationMode (l_parser, FALSE);
        DBMS_XMLPARSER.parseBuffer (l_parser, xmlString);
        l_xmldoc := DBMS_XMLPARSER.getDocument (l_parser);
        l_elem := xmldom.getDocumentElement (l_xmldoc);
        l_node := DBMS_XMLDOM.makenode (l_xmldoc);
        --результат работы
        XmlRootNode := DBMS_XMLDOM.getfirstchild (l_node);
        XmlRootNodeName := DBMS_XMLDOM.getNodeName (XmlRootNode);
    END GetRootNode;

    PROCEDURE GetChildNodes (XmlNode         IN     DBMS_XMLDOM.DOMNode,
                             XmlChildNodes      OUT DBMS_XMLDOM.DOMNodelist,
                             v_countNodes       OUT NUMBER)
    IS
    BEGIN
        XmlChildNodes := DBMS_XMLDOM.getChildNodes (XmlNode);
        v_countNodes := DBMS_XMLDOM.getLength (XmlChildNodes);
    END;

    -- процедура для выбора значения узла и значения его атрибутов
    PROCEDURE GetNodesData (XmlNode            IN     DBMS_XMLDOM.DOMNode,
                            XmlNodeName           OUT VARCHAR2, -- навзвание узла
                            XmlNodeText           OUT VARCHAR2,  -- текст узла
                            XmlNodeAttribute      OUT XmlAtribute) -- атрибуты узла
    IS
        v_Attrs          DBMS_XMLDOM.DOMNamedNodeMap;         -- атрибуты узла
        v_countAttr      NUMBER;                      -- колличество атрибутов
        v_Attr           DBMS_XMLDOM.DOMNode;
        i                INTEGER;
        XmlAttr          ikis_sysweb.XMLATRIBUTE := ikis_sysweb.XMLATRIBUTE ();
        AttributeName    VARCHAR2 (30);
        AttributeValue   VARCHAR2 (30);
        v_node_text      DBMS_XMLDOM.DOMNode;
    BEGIN
        XmlNodeName := DBMS_XMLDOM.getNodeName (XmlNode);

        -- проверяем наличие атрибутов елемента
        v_Attrs := DBMS_XMLDOM.getAttributes (XmlNode);
        v_countAttr := DBMS_XMLDOM.getLength (v_Attrs);

        IF v_countAttr > 0
        THEN
            FOR i IN 0 .. v_countAttr - 1
            LOOP
                v_Attr := DBMS_XMLDOM.item (v_Attrs, i);
                AttributeName := DBMS_XMLDOM.getNodeName (v_Attr);
                AttributeValue := DBMS_XMLDOM.getNodeValue (v_Attr);
                XmlAttr.EXTEND;
                XmlAttr (XmlAttr.LAST) :=
                    t_xml_atribute (AttributeName, AttributeValue);
            END LOOP;
        ELSE
            NULL;
        END IF;

        -- проверяем значение елемента
        v_node_text := DBMS_XMLDOM.getFirstChild (XmlNode);
        XmlNodeText := DBMS_XMLDOM.getNodeValue (v_node_text);
    END;

    PROCEDURE GetNodeValue (XmlString   IN     VARCHAR2,
                            NodeName    IN     VARCHAR2,
                            NodeValue      OUT VARCHAR2)
    IS
        xml_str    XMLTYPE;
        xml_res    XMLTYPE;
        xml_res1   VARCHAR2 (10000);
        i          INTEGER;
    BEGIN
        --dbms_output.put_line('Значение переменной внутри процедуры '||XmlString);
        xml_str := xmltype (XmlString);
        NodeValue :=
            xml_str.EXTRACT ('//' || NodeName || '/text()').getStringVal ();
    EXCEPTION
        WHEN OTHERS
        THEN
            BEGIN
                IF SQLCODE = -30625
                THEN
                    NodeValue := '';
                ELSE
                    RAISE;
                END IF;
            END;
    END;
END IKIS_XML;
/