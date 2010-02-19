<!-----------------------------------------------------------------------
		<cfscript>
		<cfargument name="aCFC" type="array" required="true"/>
		<cfset instance.aCFC = arguments.aCFC/>
	</cffunction>
		<cfreturn instance.aPacks/>
	</cffunction>
	<cffunction name="setaPacks" access="public" output="false" returntype="void" hint="Set aPacks">
		<cfargument name="aPacks" type="array" required="true"/>
		<cfset instance.aPacks = arguments.aPacks/>
	</cffunction>
		<cfreturn instance.linkType/>
	</cffunction>
	<cffunction name="setlinkType" access="public" output="false" returntype="void" hint="Set linkType">
		<cfargument name="linkType" type="string" required="true"/>
		<cfset instance.linkType = arguments.linkType/>
	</cffunction>
		<cfreturn instance.linkString/>
	</cffunction>
	<cffunction name="setlinkString" access="public" output="false" returntype="void" hint="Set linkString">
		<cfargument name="linkString" type="string" required="true"/>
			<cfset instance.linkString = left(arguments.linkstring, len(arguments.linkstring)-1) />
	</cffunction>
		<cfreturn instance.rootPath/>
	</cffunction>
	<cffunction name="setrootPath" access="public" output="false" returntype="void" hint="Set rootPath">
		<cfargument name="rootPath" type="string" required="true"/>
		<cfset instance.rootPath = arguments.rootPath/>
	</cffunction>
		<cfreturn instance.RenderingTemplate>
	</cffunction>
	<cffunction name="setRenderingTemplate" access="public" returntype="void" output="false" hint="Set the rendering template to use">
		<cfargument name="RenderingTemplate" type="string" required="true">
		<cfset instance.RenderingTemplate = arguments.RenderingTemplate>
	</cffunction>
		<cfreturn instance.LinkBaseURL>
	</cffunction>
	<cffunction name="setLinkBaseURL" access="public" returntype="void" output="false">
		<cfargument name="LinkBaseURL" type="string" required="true">
		<cfset instance.LinkBaseURL = arguments.LinkBaseURL>
	</cffunction>