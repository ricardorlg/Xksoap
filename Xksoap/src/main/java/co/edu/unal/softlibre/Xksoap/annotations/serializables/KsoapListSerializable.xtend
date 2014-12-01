package co.edu.unal.softlibre.Xksoap.annotations.serializables

import java.io.Serializable
import java.lang.annotation.ElementType
import java.lang.annotation.Target
import java.util.List
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.InterfaceDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.ksoap2.serialization.KvmSerializable
import org.ksoap2.serialization.SoapObject
import org.ksoap2.serialization.SoapPrimitive

import static co.edu.unal.softlibre.Xksoap.utils.Utils.*

@Active(typeof(ksoapListSerializableCompilationParticipant))
@Target(ElementType.TYPE)
annotation KsoapListSerializable {
	String elementName
}

class ksoapListSerializableCompilationParticipant extends AbstractClassProcessor {
	override doTransform(List<? extends MutableClassDeclaration> annotatedClasses,
		extension TransformationContext context) {
		annotatedClasses.forEach[doTransform(it, context)]
	}

	override doTransform(MutableClassDeclaration clazz, extension TransformationContext context) {
		if (clazz.extendedClass == Object.newTypeReference()) {
			clazz.annotations.head.addError("this class must extends of vector class")

		}
		val tipo = clazz.extendedClass.actualTypeArguments.get(0)
		val tipo2 = tipo.type as ClassDeclaration

		val parameterName = getValue(clazz, context)
		val interfaceUsed = KvmSerializable.newTypeReference
		val serializable = Serializable.newTypeReference()

		clazz.implementedInterfaces = clazz.implementedInterfaces + #[interfaceUsed, serializable]

		clazz.addConstructor [
			addParameter("object", SoapObject.newTypeReference())
			body = [
				'''
					int size = object.getPropertyCount();
					 for (int i0=0;i0< size;i0++)
					       {
					           Object obj = object.getProperty(i0);
					           «IF tipo2.findAnnotation(KsoapSerializable.newTypeReference().type) != null»
					           	if (obj!=null && obj instanceof «toJavaCode(SoapObject.newTypeReference())»)
					           	{
					           	SoapObject j =(SoapObject) object.getProperty(i0);
					           	«toJavaCode(tipo)» j1= new «tipo.simpleName»(j);	
					           	add(j1);
					           	
					           	}
					           «ELSE»
					           	if (obj!=null && obj instanceof «toJavaCode(SoapPrimitive.newTypeReference())»)
					           	{
					           	SoapPrimitive j =(SoapPrimitive) object.getProperty(i0);					           	 
					           	  	«toJavaCode(tipo)» j1= «typeConverted(tipo, "j")»;
					           	add(j1);
					           	}
					           «ENDIF»
					
					       }
				'''
			]
		]
		val s = interfaceUsed.type as InterfaceDeclaration
		for (method : s.declaredMethods) {

			if (method.simpleName.equalsIgnoreCase("getPropertyCount")) {
				clazz.addMethod(method.simpleName) [
					for (p : method.parameters) {
						addParameter(p.simpleName, p.type)
					}
					returnType = method.returnType
					body = [
						'''
							return this.size();
						''']
				]
			} else if (method.simpleName.equalsIgnoreCase("getProperty")) {
				clazz.addMethod(method.simpleName) [
					for (p : method.parameters) {
						addParameter('index', p.type)
					}
					returnType = method.returnType
					body = [
						'''
							return this.get(index);
						''']
				]
			} else if (method.simpleName.equalsIgnoreCase("getPropertyInfo")) {
				clazz.addMethod(method.simpleName) [
					for (p : method.parameters) {
						addParameter(p.simpleName, p.type)
					}
					returnType = method.returnType
					body = [
						'''
							arg2.name="«parameterName»";
							arg2.type=«toJavaCode(tipo)».class;
						''']
				]
			} else {
				clazz.addMethod(method.simpleName) [
					for (p : method.parameters) {
						addParameter(p.simpleName, p.type)
					}
					returnType = method.returnType
					body = [
						'''
							this.add(«typeConverted(tipo, "arg1")»);
						''']
				]
			}
		}
	}

	

	def String getValue(MutableClassDeclaration annotatedClass, extension TransformationContext context) {

		val value = annotatedClass.annotations.findFirst [
			annotationTypeDeclaration == KsoapListSerializable.newTypeReference.type
		].getValue("elementName")

		if(value == null) return null

		return value.toString
	}

}
