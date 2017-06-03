SELECT DISTINCT FilteredRole.name AS [Role Name], 
	EntityView.PhysicalName AS [Entity Name], 
	CASE Privilege.AccessRight 
		WHEN 1 THEN 'Read' 
		WHEN 2 THEN 'Write' 
		WHEN 4 THEN 'Append' 
		WHEN 16 THEN 'AppendTo' 
		WHEN 32 THEN 'Create' 
		WHEN 65536 THEN 'Delete' 
		WHEN 262144 THEN 'Share' 
		WHEN 524288 THEN 'Assign' 
	END AS [Access Level], 
	CASE PrivilegeDepthMask 
		WHEN 1 THEN 'User' 
		WHEN 2 THEN 'Business Unit' 
		WHEN 4 THEN 'Parent: Child Business Unit' 
		WHEN 8 THEN 'Organisation' 
	END AS [Security Level] 
FROM FilteredRole
	INNER JOIN RolePrivileges ON FilteredRole.roleid = RolePrivileges.RoleId
	INNER JOIN Privilege ON RolePrivileges.PrivilegeId = Privilege.PrivilegeId 
	INNER JOIN PrivilegeObjectTypeCodes ON RolePrivileges.PrivilegeId = PrivilegeObjectTypeCodes.PrivilegeId 
	INNER JOIN EntityView ON EntityView.ObjectTypeCode = PrivilegeObjectTypeCodes.ObjectTypeCode 
ORDER BY [Role Name], [Entity Name]
-------------------------------------------------------------------------------------
SELECT DISTINCT r.Name AS [Role Name]
        ,COALESCE(e.OriginalLocalizedName, e.Name) AS [EntityName]
        ,CASE p.AccessRight
             WHEN 32     THEN 'Create' /* or hex value 0x20*/
             WHEN 1      THEN 'Read'
             WHEN 2      THEN 'Write'
             WHEN 65536  THEN 'Delete' /* or hex value 0x10000*/
             WHEN 4      THEN 'Append'
             WHEN 16     THEN 'AppendTo'
             WHEN 524288 THEN 'Assign' /* or hex value 0x80000*/
             WHEN 262144 THEN 'Share' /* or hex value 0x40000*/
             ELSE 'None'
        END AS [Privilege]
        ,CASE (rp.PrivilegeDepthMask % 0x0F)
             WHEN 1 THEN 'User (Basic)'
             WHEN 2 THEN 'Business Unit (Local)'
             WHEN 4 THEN 'Parental (Deep)'
             WHEN 8 THEN 'Organization (Global)'
             ELSE 'Unknown'
        END AS [PrivilegeLevel]
        ,(rp.PrivilegeDepthMask % 0x0F) as [PrivilegeDepthMask]
        ,CASE WHEN e.IsCustomEntity = 1 THEN 'Yes' ELSE 'No' END AS [IsCustomEntity]
FROM  FilteredRole AS r
INNER JOIN RolePrivileges AS rp ON r.RoleId = rp.RoleId
INNER JOIN Privilege AS p ON rp.PrivilegeId = p.PrivilegeId
INNER JOIN PrivilegeObjectTypeCodes AS potc ON potc.PrivilegeId = p.PrivilegeId
INNER JOIN EntityView AS e ON e.ObjectTypeCode = potc.ObjectTypeCode
ORDER BY [Role Name], [EntityName]
