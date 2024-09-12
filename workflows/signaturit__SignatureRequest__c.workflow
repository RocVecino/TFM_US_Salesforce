<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>signaturit__Signaturit_Request_Error</fullName>
        <description>Alert for signaturit created request error</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>signaturit__Signaturit/signaturit__Signaturit_Request_Error_Email</template>
    </alerts>
    <rules>
        <fullName>signaturit__Signaturit Request Error</fullName>
        <actions>
            <name>signaturit__Signaturit_Request_Error</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>signaturit__SignatureRequest__c.signaturit__Status__c</field>
            <operation>equals</operation>
            <value>error</value>
        </criteriaItems>
        <description>Alert for signaturit created request error</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
