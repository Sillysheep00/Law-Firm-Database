DROP TABLE feedback CASCADE CONSTRAINTS;
DROP TABLE conviction CASCADE CONSTRAINTS;
DROP TABLE Clients CASCADE CONSTRAINTS;
DROP TABLE Lawyer CASCADE CONSTRAINTS;
DROP TABLE Trial CASCADE CONSTRAINTS;
DROP TABLE code_of_law CASCADE CONSTRAINTS;
DROP TABLE court CASCADE CONSTRAINTS;
DROP TABLE PAYMENTS CASCADE CONSTRAINTS;
DROP TABLE Case CASCADE CONSTRAINTS;
DROP TABLE judges CASCADE CONSTRAINTS;
DROP TABLE JUDGE_ASSIGNED CASCADE CONSTRAINTS;
DROP TABLE FIELD_OF_EXPERTISE CASCADE CONSTRAINTS;
DROP TABLE LAWYER_FIELD_EXPERTISE CASCADE CONSTRAINTS;

-- Creating tables with corrected constraints and relationships
CREATE TABLE Clients (
    Client_ID CHAR(5) CONSTRAINT pk_client_id PRIMARY KEY,
    Client_Name VARCHAR2(30),
    Client_Address VARCHAR2(40),
    Client_Contact_Number CHAR(10)
);

CREATE TABLE Lawyer (
    Lawyer_ID CHAR(6) CONSTRAINT pk_lawyer_id PRIMARY KEY,
    Lawyer_Name VARCHAR2(30),
    Lawyer_Address VARCHAR2(50),
    Lawyer_Contact_Number CHAR(10),
    Lawyer_Email VARCHAR2(40),
    Date_Joined DATE
);
CREATE OR REPLACE TRIGGER trg_lawyer_date_joined
BEFORE INSERT OR UPDATE ON Lawyer
FOR EACH ROW
BEGIN
    IF :new.Date_Joined > SYSDATE THEN
        RAISE_APPLICATION_ERROR(-20002, 'Date Joined cannot be in the future');
    END IF;
END;
/

CREATE TABLE judges (
    Judge_ID NUMBER(6, 0) PRIMARY KEY,
    Judge_Name VARCHAR2(30),
    Judge_Address VARCHAR2(40),
    Judge_Contact_Number CHAR(10),
    Experience_Level VARCHAR2(20)
);

CREATE TABLE Case (
    Case_ID CHAR(7) CONSTRAINT pk_Case PRIMARY KEY,
    Client_ID CHAR(5),
    Lawyer_ID CHAR(6),
    Case_Date DATE,
    CONSTRAINT fk_Client FOREIGN KEY (Client_ID) REFERENCES Clients(Client_ID),
    CONSTRAINT fk_Lawyer FOREIGN KEY (Lawyer_ID) REFERENCES Lawyer(Lawyer_ID)
);
CREATE OR REPLACE TRIGGER trg_case_date
BEFORE INSERT OR UPDATE ON Case
FOR EACH ROW
BEGIN
    IF :new.Case_Date > SYSDATE THEN
        RAISE_APPLICATION_ERROR(-20001, 'Case date cannot be in the future');
    END IF;
END;
/

CREATE TABLE court(
    Court_ID NUMBER(3, 0) PRIMARY KEY,
    class_type CHAR(1) CHECK (class_type IN ('A', 'B', 'C')),
    court_location CHAR(5)
);

INSERT INTO court VALUES ('1','A','R1');
INSERT INTO court VALUES ('2','B','R2');
INSERT INTO court VALUES ('3','A','R3');
INSERT INTO court VALUES ('4','A','R4');
INSERT INTO court VALUES ('5','C','R5');
INSERT INTO court VALUES ('6','A','R6');
INSERT INTO court VALUES ('7','C','R7');
INSERT INTO court VALUES ('8','A','R8');
INSERT INTO court VALUES ('9','B','R9');
INSERT INTO court VALUES ('10','B','R10');
INSERT INTO court VALUES ('11','C','R11');
INSERT INTO court VALUES ('12','A','R12');
INSERT INTO court VALUES ('13','B','R13');
INSERT INTO court VALUES ('14','C','R14');
INSERT INTO court VALUES ('15','C','R15');


CREATE TABLE feedback (
    feedback_ID CHAR(8) PRIMARY KEY, 
    feedback_Date DATE, 
    Case_ID CHAR(7), 
    Client_ID CHAR(5), 
    Lawyer_ID CHAR(6), 
    Overall_Satisfaction NUMBER(1) CHECK (Overall_Satisfaction BETWEEN 1 AND 5),
    FOREIGN KEY (Client_ID) REFERENCES Clients(Client_ID),
    FOREIGN KEY (Lawyer_ID) REFERENCES Lawyer(Lawyer_ID),
    FOREIGN KEY (Case_ID) REFERENCES Case(Case_ID)
);


CREATE TABLE code_of_law (
    Law_ID CHAR(5) PRIMARY KEY,
    Violation VARCHAR2(50),
    Description CLOB,
    Penalty VARCHAR2(100)
);

INSERT INTO code_of_law VALUES ('01B','Murder','Murder wife','life imprisonment');
INSERT INTO code_of_law VALUES ('02C','Robbery','Robe a shop','sentence to jail 2 years');
INSERT INTO code_of_law VALUES ('03A','Sexual Assault','Child sexual abuse','sentence to jail 10 years');
INSERT INTO code_of_law VALUES ('04B','Posioning','Poison own child','life imprisonment');
INSERT INTO code_of_law VALUES ('05A', 'Assault', 'Intentional causing of bodily harm to another person', 'Sentence to jail 3 years');
INSERT INTO code_of_law VALUES ('06C', 'Burglary', 'Illegal entry into a building with the intent to commit a crime', 'Sentence to jail 10 years');
INSERT INTO code_of_law VALUES ('07B', 'Embezzlement', 'Misappropriation of funds entrusted to one care', 'Sentence to jail 8 years');
INSERT INTO code_of_law VALUES ('08A', 'Drug Trafficking', 'Illegal distribution and sale of controlled substances', 'Life imprisonment');
INSERT INTO code_of_law VALUES ('09B', 'Cybercrime', 'Illegal activities conducted on the internet', 'Sentence to jail 12 years');
INSERT INTO code_of_law VALUES ('10C', 'Public Intoxication', 'Being drunk in public places', 'Fine and community service');
INSERT INTO code_of_law VALUES ('11B', 'Environmental Pollution', 'Contamination of the environment with harmful substances', 'Fine and cleanup costs');
INSERT INTO code_of_law VALUES ('12A','Trespassing','Entering someone else property without permission','Sentence to jail 6 months');
INSERT INTO code_of_law VALUES ('13C','Forgery','Fraudulent creation or alteration of documents','Sentence to jail 5 years');
INSERT INTO code_of_law VALUES ('14A','Stalking','Persistent unwanted attention towards another person','Sentence to jail 2 years');
INSERT INTO code_of_law VALUES ('15C','Hate Crime','Criminal act motivated by bias or prejudice','Enhanced penalties based on severity');


CREATE TABLE Trial (
    Trial_ID CHAR(8) CONSTRAINT pk_trial_id PRIMARY KEY,
    Trial_Date DATE,
    Trial_Status VARCHAR2(10),
    Court_ID NUMBER(3, 0),
    Case_ID CHAR(7),
    Client_ID CHAR(5),
    Lawyer_ID CHAR(6),
    Judge_ID NUMBER(6),
    FOREIGN KEY (Court_ID) REFERENCES court(Court_ID),
    FOREIGN KEY (Case_ID) REFERENCES Case(Case_ID),
    FOREIGN KEY (Client_ID) REFERENCES Clients(Client_ID),
    FOREIGN KEY (Lawyer_ID) REFERENCES Lawyer(Lawyer_ID),
    FOREIGN KEY (Judge_ID) REFERENCES judges(Judge_ID)
);
CREATE OR REPLACE TRIGGER trg_trial_date
BEFORE INSERT OR UPDATE ON Trial
FOR EACH ROW
BEGIN
    IF :new.Trial_Date > SYSDATE THEN
        RAISE_APPLICATION_ERROR(-20003, 'Trial date cannot be in the future');
    END IF;
END;
/


CREATE TABLE conviction (
    Law_ID CHAR(5),
    Trial_ID CHAR(8),
    PRIMARY KEY (Law_ID, Trial_ID),
    FOREIGN KEY (Law_ID) REFERENCES code_of_law(Law_ID),
    FOREIGN KEY (Trial_ID) REFERENCES Trial(Trial_ID)
);

CREATE TABLE PAYMENTS (
    PAYMENTS_ID CHAR(3) PRIMARY KEY , 
    Case_ID CHAR(7) NOT NULL, 
    payer VARCHAR(8) CHECK (payer IN ('Client','Opposing')), 
    PAYMENTS_stat VARCHAR(10) CHECK (PAYMENTS_stat IN ('Successful','Unpaid')),
    PAYMENTS_amt DECIMAL(7,2) CHECK (PAYMENTS_amt >= 0) NOT NULL,
    PAYMENTS_date DATE
);

INSERT INTO PAYMENTS VALUES('A01','CG42801','Client','Successful',14450,TO_DATE('2023-06-01','YYYY-MM-DD'));
INSERT INTO PAYMENTS VALUES('A02','CG42802','Client','Successful',15050,TO_DATE('2023-06-02','YYYY-MM-DD'));
INSERT INTO PAYMENTS VALUES('B03','CG42803',NULL,'Unpaid',20000,NULL);
INSERT INTO PAYMENTS VALUES('B04','CG42804','Client','Successful',13400,TO_DATE('2023-06-10','YYYY-MM-DD'));
INSERT INTO PAYMENTS VALUES('C05','CG42805','Opposing','Successful',14000,TO_DATE('2023-08-15','YYYY-MM-DD'));
INSERT INTO PAYMENTS VALUES('D06','CG42806','Opposing','Successful',24000,TO_DATE('2023-07-20','YYYY-MM-DD'));
INSERT INTO PAYMENTS VALUES('C07','CG42807',NULL,'Unpaid',10890,NULL);
INSERT INTO PAYMENTS VALUES('C08','CG42808','Client','Successful',16700,TO_DATE('2023-08-01','YYYY-MM-DD'));
INSERT INTO PAYMENTS VALUES('A09','CG42809','Client','Successful',13500,TO_DATE('2023-08-14','YYYY-MM-DD'));
INSERT INTO PAYMENTS VALUES('B10','CG42810',NULL,'Unpaid',18900,NULL);
INSERT INTO PAYMENTS VALUES('D11','CG42811',NULL,'Unpaid',6700,NULL);
INSERT INTO PAYMENTS VALUES('A12','CG42812','Client','Successful',5400,TO_DATE('2023-10-18','YYYY-MM-DD'));
INSERT INTO PAYMENTS VALUES('D13','CG42813',NULL,'Unpaid',23450,NULL);
INSERT INTO PAYMENTS VALUES('B14','CG42814',NULL,'Unpaid',9700,NULL);
INSERT INTO PAYMENTS VALUES('C15','CG42815','Client','Successful',12340,TO_DATE('2023-10-23','YYYY-MM-DD'));
INSERT INTO PAYMENTS VALUES('A16','CG42816','Client','Pending',13455,NULL);
INSERT INTO PAYMENTS VALUES('A17','CG42817','Opposing','Successful',15670,TO_DATE('2023-10-27','YYYY-MM-DD'));
INSERT INTO PAYMENTS VALUES('D18','CG42818',NULL,'Unpaid',17890,NULL);
INSERT INTO PAYMENTS VALUES('C19','CG42819',NULL,'Unpaid',27800,NULL);
INSERT INTO PAYMENTS VALUES('B20','CG42820','Opposing','Successful',5000,TO_DATE('2023-12-25','YYYY-MM-DD'));


CREATE TABLE JUDGE_ASSIGNED (
    Judge_ID NUMBER(6),
    Trial_ID CHAR(8),
    PRIMARY KEY (Judge_ID, Trial_ID),
    FOREIGN KEY (Judge_ID) REFERENCES judges(Judge_ID),
    FOREIGN KEY (Trial_ID) REFERENCES Trial(Trial_ID)
);

CREATE TABLE FIELD_OF_EXPERTISE (
    Field_ID NUMBER PRIMARY KEY CHECK (Field_ID > 0),
    Field_Name VARCHAR2(255) NOT NULL,
    Field_Description CLOB
);

CREATE TABLE LAWYER_FIELD_EXPERTISE (
    Lawyer_ID CHAR(6),  
    Field_ID NUMBER,
    PRIMARY KEY (Lawyer_ID, Field_ID),
    FOREIGN KEY (Lawyer_ID) REFERENCES Lawyer(Lawyer_ID),
    FOREIGN KEY (Field_ID) REFERENCES FIELD_OF_EXPERTISE(Field_ID)
);








