package co.edu.unal.softlibre.Xksoap.annotations.services

import java.io.IOException
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.TypeReference
import org.eclipse.xtend.lib.macro.declaration.Visibility
import org.ksoap2.SoapEnvelope
import org.ksoap2.SoapFault
import org.ksoap2.serialization.MarshalBase64
import org.ksoap2.serialization.MarshalDate
import org.ksoap2.serialization.PropertyInfo
import org.ksoap2.serialization.SoapObject
import org.ksoap2.serialization.SoapPrimitive
import org.ksoap2.serialization.SoapSerializationEnvelope
import org.ksoap2.transport.HttpResponseException
import org.ksoap2.transport.HttpTransportSE

import static co.edu.unal.softlibre.Xksoap.utils.Utils.*

@Active(typeof(KsoapServiceCompilationParticipant))
annotation KsoapService {
	String URL
	String NAME_SPACE
	String METHOD_NAME
	String[] inputsParametersNames
	Class<?>[] inputsParametersTypes
	Class<?> typeReturn
	boolean implicitReturn = true
	boolean implicitTypes = false
}

class KsoapServiceCompilationParticipant extends AbstractClassProcessor {
	var validTypes = #['Boolean', 'Long', 'Integer', 'String', 'Float', 'Double', 'Date', 'byte[]', 'Character']

	override doTransform(MutableClassDeclaration clazz, extension TransformationContext context) {
		createFields(clazz, context)
		createServiceConsumeMethod(clazz, context)
		createServiceMethod(clazz, context)
	}

	def createServiceConsumeMethod(MutableClassDeclaration clazz, extension TransformationContext context) {
		clazz.addMethod("Execute") [
			visibility = Visibility.PUBLIC
			returnType = SoapObject.newTypeReference
			exceptions = #[Exception.newTypeReference()]
			val clases = getArrayClassValue(clazz, context, "inputsParametersTypes")
			val nombres = getArrayStringValue(clazz, context, "inputsParametersNames")
			val impliciTypes = getBooleanValue(clazz, context, 'implicitTypes')
			if (clases.size != nombres.size) {
				clazz.annotations.head.addError(
					"Error, inputsParametersNames and inputsParametersTypes must have same dimension")
			}
			for (i : 0 .. clases.size - 1) {
				addParameter(nombres.get(i), clases.get(i))
			}
			body = [
				'''
					«toJavaCode(SoapObject.newTypeReference())» request = new SoapObject(NAME_SPACE,METHOD_NAME);
						«FOR i : 0 .. clases.size - 1»
							«toJavaCode(PropertyInfo.newTypeReference())» propertyInfo«i» = new PropertyInfo();
							propertyInfo«i».setName("«nombres.get(i)»");
							propertyInfo«i».setValue(«nombres.get(i)»);
							propertyInfo«i».setType(«clases.get(i).simpleName».class);
							request.addProperty(propertyInfo«i»);
						«ENDFOR»
					«toJavaCode(SoapSerializationEnvelope.newTypeReference())» envelope = new SoapSerializationEnvelope(«toJavaCode(
						SoapEnvelope.newTypeReference())».VER11);
					envelope.implicitTypes=«impliciTypes»;
					envelope.setOutputSoapObject(request);
						«IF clazz.findDeclaredMethod('configureEnvelope', SoapSerializationEnvelope.newTypeReference()) != null»
							configureEnvelope(envelope);
						«ENDIF»
					new «toJavaCode(MarshalDate.newTypeReference())»().register(envelope);
					new «toJavaCode(MarshalBase64.newTypeReference())»().register(envelope);
					try {
							«toJavaCode(HttpTransportSE.newTypeReference())» transp = new HttpTransportSE(URL, 6000);
							transp.debug = true;
							«toJavaCode(System.newTypeReference)».setProperty("http.keepAlive", "false");
							transp.call(NAME_SPACE + METHOD_NAME, envelope);
							android.util.Log.i("REQUEST--->", transp.requestDump);
							android.util.Log.i("RESPONSE--->", transp.responseDump);
							Object result = envelope.bodyIn;
							SoapObject _retObject = (SoapObject) result;
							if (result instanceof «toJavaCode(SoapFault.newTypeReference())») {
								SoapFault fault = (SoapFault) result;
								throw new Exception(fault.toString());
								}
							transp.reset();
					return _retObject;
					} catch («toJavaCode(HttpResponseException.newTypeReference())» ex2) {
							String message;
							if(ex2.getLocalizedMessage()!=null){
								message= ex2.getLocalizedMessage()+" Code ="+ex2.getStatusCode();
							}else{
								message="Error HttpCode = "+ex2.getStatusCode();
							}
							android.util.Log.d("httpResponseError", message);
							throw ex2;
					} catch («toJavaCode(IOException.newTypeReference())» ex) {
							String message;
							if(ex.getLocalizedMessage()!=null){
								message= ex.getLocalizedMessage();
							}else{
								message="Error desconocido";
							}
								android.util.Log.d("IOError", message);
							throw ex;
							}
				'''
			]
		]
	}

	def createServiceMethod(MutableClassDeclaration clazz, extension TransformationContext context) {
		val method_name = getStringValue(clazz, context, "METHOD_NAME")
		val returnedType = getClassValue(clazz, context, "typeReturn")
		clazz.addMethod('do' + method_name.toLowerCase.toFirstUpper) [
			visibility = Visibility.PUBLIC
			returnType = returnedType
			exceptions = #[Exception.newTypeReference()]
			val clases = getArrayClassValue(clazz, context, "inputsParametersTypes")
			val nombres = getArrayStringValue(clazz, context, "inputsParametersNames")
			val returnTypeimplicit = getBooleanValue(clazz, context, 'implicitReturn')
			if (clases.size != nombres.size) {
				clazz.annotations.head.addError(
					"Error, inputsParametersNames and inputsParametersTypes must have same dimension")
			}
			for (i : 0 .. clases.size - 1) {
				addParameter(nombres.get(i), clases.get(i))
			}
			body = [
				'''
					«IF validTypes.contains(returnedType.simpleName)»
						SoapObject rpta=Execute(«nombres.toString.replace('[', '').replace(']', '')»);
						Object obj = rpta.getProperty("return");
						if (obj != null && obj.getClass().equals(SoapPrimitive.class))
							{
								«toJavaCode(SoapPrimitive.newTypeReference)» j =(SoapPrimitive) rpta.getProperty("return");
								return «typeConverted(returnedType, 'j')»;
							}
						return null;
					«ELSE»
						SoapObject rpta=Execute(«nombres.toString.replace('[', '').replace(']', '')»);
						«IF returnTypeimplicit»
							Object obj = rpta.getProperty("return");
							if (obj != null && obj.getClass().equals(SoapObject.class))
							{
								«toJavaCode(SoapObject.newTypeReference)» j =(SoapObject) rpta.getProperty("return");
								return new «toJavaCode(returnedType)» (j);
							}
							return null;
						«ELSE»
							return new «toJavaCode(returnedType)» (rpta);
						«ENDIF»
					«ENDIF»
				'''
			]
		]
	}

	def createFields(MutableClassDeclaration clazz, extension TransformationContext context) {
		clazz.addField("URL") [
			final = true
			type = String.newTypeReference()
			initializer = ['''"«getStringValue(clazz, context, "URL")»"''']
		]
		clazz.addField("NAME_SPACE") [
			type = String.newTypeReference()
			final = true
			initializer = ['''"«getStringValue(clazz, context, "NAME_SPACE")»"''']
		]
		clazz.addField("METHOD_NAME") [
			final = true
			type = String.newTypeReference()
			initializer = ['''"«getStringValue(clazz, context, "METHOD_NAME")»"''']
		]
	}

	def String getStringValue(MutableClassDeclaration annotatedClass, extension TransformationContext context,
		String propertyName) {
		val value = annotatedClass.annotations.findFirst [
			annotationTypeDeclaration == KsoapService.newTypeReference.type
		].getValue(propertyName)
		if(value == null) return null
		return value.toString
	}

	def getBooleanValue(MutableClassDeclaration annotatedClass, extension TransformationContext context,
		String propertyName) {
		val value = annotatedClass.annotations.findFirst [
			annotationTypeDeclaration == KsoapService.newTypeReference.type
		].getValue(propertyName)
		if(value == null) return null
		return (value as Boolean)
	}

	def String[] getArrayStringValue(MutableClassDeclaration annotatedClass, extension TransformationContext context,
		String propertyName) {
		val value = annotatedClass.annotations.findFirst [
			annotationTypeDeclaration == KsoapService.newTypeReference.type
		].getValue(propertyName)
		if(value == null) return null
		return value as String[]
	}

	def getArrayClassValue(MutableClassDeclaration annotatedClass, extension TransformationContext context,
		String propertyName) {
		val value = annotatedClass.annotations.findFirst [
			annotationTypeDeclaration == KsoapService.newTypeReference.type
		].getClassArrayValue(propertyName)
		if(value == null) return null
		return value
	}

	def TypeReference getClassValue(MutableClassDeclaration annotatedClass, extension TransformationContext context,
		String propertyName) {
		val value = annotatedClass.annotations.findFirst [
			annotationTypeDeclaration == KsoapService.newTypeReference.type
		].getValue(propertyName)
		if(value == null) return null
		return value as TypeReference
	}

}
