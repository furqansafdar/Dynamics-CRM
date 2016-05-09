-- =============================================
-- Author:		Furqan Safdar
-- Create date: 09-May-2016
-- Description:	CRM 2011 Entity's Form based Security Role report script
-- =============================================
select 
	entity.ObjectTypeCode [EntityObjectTypeCode],
	entity.EntityId, 
	entity.Name [EntityName], 
	sysForm.FormId, 
	sysForm.Name [FormName], 
	formType.Value [FormType], 
	i.value('@Id', 'uniqueidentifier') [RoleId], 
	r.Name [RoleName]
from EntityAsIfPublishedView entity with (nolock)
	left join
	(
		select ObjectTypeCode, FormId, Name, [Type], convert(XML, FormXml) [FormXml]
		from SystemFormAsIfPublished with (nolock)
	) sysForm 
		on sysForm.ObjectTypeCode = entity.ObjectTypeCode
	inner join 
	(
		select AttributeValue, Value 
		from StringMap with (nolock)
		where AttributeName = 'type' 
		and LangId = 1033
		and ObjectTypeCode = (select ObjectTypeCode from EntityAsIfPublishedView where Name = 'SystemForm')
	) formType
		on formType.AttributeValue = sysForm.Type
	outer apply 
		sysForm.FormXml.nodes('/form/DisplayConditions/Role') x(i)
	inner join RoleAsIfPublished r with (nolock)
		on r.RoleId = i.value('@Id', 'uniqueidentifier')		
order by entity.EntityId, sysForm.FormId, r.RoleId