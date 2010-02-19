<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	9/28/2007
Description :
	This object models an interception state
----------------------------------------------------------------------->
<cfcomponent name="InterceptorState"
			 hint="I am a pool of interceptors that can execute on a state or interception value."
			 output="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->
	<cfscript>
		variables.instance = structnew();
	</cfscript>
	
	<cffunction name="init" access="public" output="false" hint="constructor" returntype="InterceptorState">
	    <!--- ************************************************************* --->
	    <cfargument name="state" 		type="string" 	required="true" hint="The interception state I model">
	    <!--- ************************************************************* --->
		<cfscript>
			var LinkedHashMap = CreateObject("java","java.util.LinkedHashMap").init(3);
			var Collections = createObject("java", "java.util.Collections"); 
			
			// Create the interceptor container, start with 3 instead of 16 to save space
			setInterceptors( Collections.synchronizedMap(LinkedHashMap) );
			setState( arguments.state );
			
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- Register a new interceptor with this state --->
	<cffunction name="register" access="public" returntype="void" hint="Register an interceptor class with this state" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="InterceptorKey" 	required="true" type="string" 	hint="The interceptor key class to register">
		<cfargument name="Interceptor" 		required="true" type="any" 		hint="The interceptor reference from the cache.">
		<!--- ************************************************************* --->
		<cfset getInterceptors().put(arguments.interceptorKey, arguments.Interceptor)>
	</cffunction>
	
	<!--- Remove an interceptor key from this state --->
	<cffunction name="unregister" access="public" returntype="void" hint="Unregister an interceptor class from this state" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="InterceptorKey" 	required="true" type="string" 	hint="The interceptor key class to Unregister">
		<!--- ************************************************************* --->
		<cfset getInterceptors().remove(arguments.interceptorKey)>
	</cffunction>	
	
	<!--- exists --->
	<cffunction name="exists" output="false" access="public" returntype="boolean" hint="Checks if the passed interceptor key already exists">
		<!--- ************************************************************* --->
		<cfargument name="InterceptorKey" 	required="true" type="string" 	hint="The interceptor key class to register">
		<!--- ************************************************************* --->
		<cfscript>
			if( structKeyExists(getInterceptors(), arguments.InterceptorKey) ){
				return true;
			}
			else{
				return false;
			}
		</cfscript>
	</cffunction>
	
	<cffunction name="getInterceptor" access="public" returntype="any" hint="Get an interceptor from this state. Else return a blank structure if not found" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="InterceptorKey" 	required="true" type="string" 	hint="The interceptor key class to Unregister">
		<!--- ************************************************************* --->
		<cfscript>
			if( structKeyExists(getInterceptors(), arguments.InterceptorKey) ){
				return structFind(getInterceptors(), arguments.InterceptorKey);
			}
			else{
				return structnew();
			}
		</cfscript>
	</cffunction>
	
	<!--- Process the Interceptors --->
	<cffunction name="process" access="public" returntype="void" hint="Process this state's interceptors" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="event" 		 required="true" 	type="any"    hint="The event context object.">
		<cfargument name="interceptData" required="true" 	type="struct" hint="A data structure used to pass intercepted information.">
		<!--- ************************************************************* --->
		<cfscript>
		var key = "";
		var stopChain = "";
		var thisInterceptor = "";
		
		// Loop and execute each interceptor as registered in order
		for( key in getInterceptors()){
			thisInterceptor = getInterceptors().get(key);
			
			// Check if we can execute this Interceptor
			if( isExecutable(thisInterceptor,arguments.event) ){
				// Invoke the execution point
				stopChain = invoker( thisInterceptor, arguments.event, arguments.interceptData );
				// Check for results
				if( stopChain ){ break; }
			}
		}		
		</cfscript>
	</cffunction>
	
	<!--- isExecutable --->
	<cffunction name="isExecutable" output="false" access="public" returntype="boolean" hint="Checks if an interceptor is executable or not">
		<cfargument name="target" type="any" required="true" hint="The target interceptor to check"/>
		<cfargument name="event"  type="any" required="true" hint="The event context object.">
		<cfscript>
			var fncMetadata = getMetadata(target[getState()]);
			
			// Check if the event pattern matches the current event, else return false
			if( structKeyExists(fncMetadata,"eventPattern") AND
				len(fncMetadata.eventPattern) AND
			    NOT reFindNoCase(fncMetadata.eventPattern, arguments.event.getCurrentEvent()) ){
				return false;
			}
			
			// No event pattern found, we can execute.
			return true;
		</cfscript>	
	</cffunction>
	
	<!--- getter setter state --->
	<cffunction name="getState" access="public" output="false" returntype="string" hint="Get the state's name">
		<cfreturn instance.state/>
	</cffunction>	
	<cffunction name="setState" access="public" output="false" returntype="void" hint="Set the state's name">
		<!--- ************************************************************* --->
		<cfargument name="state" type="string" required="true"/>
		<!--- ************************************************************* --->
		<cfset instance.state = arguments.state/>
	</cffunction>
	
	<!--- getter setter interceptors --->
	<cffunction name="getInterceptors" access="public" output="false" returntype="any" hint="Get the interceptors linked hash map">
		<cfreturn instance.interceptors/>
	</cffunction>	
	<cffunction name="setInterceptors" access="public" output="false" returntype="void" hint="Set interceptors linked hash map">
		<!--- ************************************************************* --->
		<cfargument name="interceptors" type="any" required="true"/>
		<!--- ************************************************************* --->
		<cfset instance.interceptors = arguments.interceptors/>
	</cffunction>
	
<!------------------------------------------- PRIVATE ------------------------------------------->

	<!--- Interceptor Invoker --->
	<cffunction name="invoker" access="private" returntype="any" hint="Execute an interceptor execution point" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="interceptor" 		required="true" type="any" 		hint="The interceptor reference from cache">
		<cfargument name="event" 		 	required="true" type="any" 		hint="The event context">
		<cfargument name="interceptData" 	required="true" type="any" 		hint="A metadata structure used to pass intercepted information.">
		<!--- ************************************************************* --->
		<cfset var results = false>
		
		<!--- Invoke the interceptor --->
		<cfinvoke component="#arguments.interceptor#" method="#getstate()#" returnvariable="results">
			<cfinvokeargument name="event" 			value="#arguments.event#">
			<cfinvokeargument name="interceptData" 	value="#arguments.interceptData#">
		</cfinvoke>
		
		<!--- Check if we have results --->
		<cfif isDefined("results") and isBoolean(results)>
			<cfreturn results>
		<cfelse>
			<cfreturn false>
		</cfif>			
	</cffunction>
	
</cfcomponent>
	