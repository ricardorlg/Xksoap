package co.edu.unal.softlibre.Xksoap.annotations.tests

import co.edu.unal.softlibre.Xksoap.annotations.serializables.KsoapSerializable
import java.lang.reflect.Method
import java.util.List
import org.eclipse.xtend.core.compiler.batch.XtendCompilerTester
import org.hamcrest.BaseMatcher
import org.hamcrest.Description
import org.hamcrest.Matcher
import org.junit.Test
import org.ksoap2.serialization.KvmSerializable
import org.ksoap2.serialization.PropertyInfo

import static org.hamcrest.MatcherAssert.assertThat

class KsoapSerializableTest {
	extension XtendCompilerTester compilerTester = XtendCompilerTester.newXtendCompilerTester(KsoapSerializable,
		KvmSerializable, PropertyInfo)

	@Test def testKsoapSerializable() {
		'''
			import co.edu.unal.softlibre.Xksoap.annotations.serializables.KsoapSerializable
			
			@KsoapSerializable
			
			class bean{
				String a
				int b
				Boolean c
			}
		'''.compile [
			val cls = compiledClass
			val methods = cls.declaredMethods.map[Method m|m.name]
			assertThat(methods, isKvmSerializable)
		]
	}

	def Matcher<List<String>> isKvmSerializable() {
		return new BaseMatcher<List<String>>() {
			var methodsNames = #['getPropertyCount', 'getProperty', 'getPropertyInfo', 'setProperty']

			override matches(Object arg0) {

				val actual = arg0 as List<String>
				actual.size == 4 && actual.containsAll(methodsNames)
			}

			override describeTo(Description description) {
				description.appendText("the methods names should be").appendValue(methodsNames);
			}

		};
	}
}
