package co.edu.unal.softlibre.Xksoap.annotations.serializables

import java.io.Serializable
import java.util.List
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.RegisterGlobalsContext
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.InterfaceDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.ksoap2.serialization.KvmSerializable
import org.ksoap2.serialization.SoapObject
import org.ksoap2.serialization.SoapPrimitive

import static co.edu.unal.softlibre.Xksoap.utils.Utils.*

@Active(typeof(ksoapSerializableCompilationParticipant))
annotation KsoapSerializable {
}

class ksoapSerializableCompilationParticipant extends AbstractClassProcessor {
	override doRegisterGlobals(ClassDeclaration annotatedClass, extension RegisterGlobalsContext context) {
	}

	override doTransform(List<? extends MutableClassDeclaration> annotatedClasses,
		extension TransformationContext context) {
		for (clazz : annotatedClasses) {
			doTransform(clazz, context)
		}
	}

	override doTransform(MutableClassDeclaration clazz, extension TransformationContext context) {
		val interfaceUsed = KvmSerializable.newTypeReference
		val serializable = Serializable.newTypeReference()
		clazz.implementedInterfaces = clazz.implementedInterfaces + #[interfaceUsed, serializable]
		print(clazz.declaredFields.nullOrEmpty)
		addConstructor(clazz, context)
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
							«IF clazz.declaredFields.nullOrEmpty»
								return 0;
							«ELSE»
								«IF clazz.extendedClass != Object.newTypeReference()»
									int count=super.getPropertyCount();
								«ELSE»
									int count=0;
								«ENDIF»
								return «clazz.declaredFields.size»+count;
							«ENDIF»
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
							«IF clazz.declaredFields.nullOrEmpty»
								return null;
							«ELSE»
								«IF clazz.extendedClass != Object.newTypeReference()»
									int count=super.getPropertyCount();
								«ELSE»
									int count=0;
								«ENDIF»
								«FOR i : 0 .. clazz.declaredFields.size - 1»
									if(index==count+«i»){
									return «clazz.declaredFields.toList.get(i).simpleName»;
									}
								«ENDFOR»
								«IF clazz.extendedClass != Object.newTypeReference()»
									return super.getProperty(index);
								«ELSE»
									return null;
								«ENDIF»
							«ENDIF»
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
							«IF !clazz.declaredFields.nullOrEmpty»
								«IF clazz.extendedClass != Object.newTypeReference()»
									int count=super.getPropertyCount();
								«ELSE»
									int count=0;
								«ENDIF»
								«FOR i : 0 .. clazz.declaredFields.size - 1»
									if(arg0==count+«i»){
									arg2.type=«toJavaCode(clazz.declaredFields.toList.get(i).type.wrapperIfPrimitive)».class;
									arg2.name="«clazz.declaredFields.toList.get(i).simpleName.replace('_', '')»";
									}
								«ENDFOR»
								«IF clazz.extendedClass != Object.newTypeReference()»
									super.getPropertyInfo(arg0,arg1,arg2);
								«ENDIF»
							«ENDIF»
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
							«IF !clazz.declaredFields.nullOrEmpty»
								«IF clazz.extendedClass != Object.newTypeReference()»
									int count=super.getPropertyCount();
								«ELSE»
									int count=0;
								«ENDIF»
								«FOR i : 0 .. clazz.declaredFields.size - 1»
									if(arg0==count+«i»){
									«var fieldName = clazz.declaredFields.toList.get(i).simpleName»
									«var fieldType = clazz.declaredFields.toList.get(i).type»
									this.«fieldName»=«typeConverted(fieldType.wrapperIfPrimitive, 'arg1')»;
									}
								«ENDFOR»
								«IF clazz.extendedClass != Object.newTypeReference()»
									super.setProperty(arg0,arg1);
								«ENDIF»
							«ENDIF»
						''']
				]
			}
		}
	}

	def addConstructor(MutableClassDeclaration clazz, extension TransformationContext context) {
		clazz.addConstructor [
			addParameter("object", SoapObject.newTypeReference())
			body = [
				'''
					«IF clazz.extendedClass != Object.newTypeReference()»
						super(object);
					«ENDIF»
					«IF !clazz.declaredFields.nullOrEmpty»
						«FOR i : 0 .. clazz.declaredFields.size - 1»
							«val a = clazz.declaredFields.get(i)»
							if(object.hasProperty("«a.simpleName.replace('_', '')»")){
								«toJavaCode(Object.newTypeReference)» obj=object.getProperty("«a.simpleName.replace('_', '')»");
								«IF (a.findAnnotation(KsoapObject.newTypeReference().type) == null)»
									if(obj!=null && obj.getClass().equals(SoapPrimitive.class)){
									«toJavaCode(SoapPrimitive.newTypeReference)» value=(SoapPrimitive) obj;
									if(value.toString()!=null){
										this.«a.simpleName»=«typeConverted(a.type.wrapperIfPrimitive, "value")»;
									}
									}else if(obj!=null && obj instanceof «a.type.wrapperIfPrimitive.simpleName»){
										this.«a.simpleName»=(«a.type.wrapperIfPrimitive» ) obj;
									}
								«ELSE»
									this.«a.simpleName»=new «a.type.simpleName»((SoapObject) obj);
								«ENDIF»
								}
						«ENDFOR»
					«ENDIF»
				'''
			]
		]
	}

}
