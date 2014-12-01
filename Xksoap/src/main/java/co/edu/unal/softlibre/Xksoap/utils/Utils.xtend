package co.edu.unal.softlibre.Xksoap.utils

import java.util.Date
import java.text.SimpleDateFormat
import org.eclipse.xtend.lib.macro.declaration.TypeReference

class Utils {
	val static formats = #[
		"yyyy-MM-dd'T'HH:mm:ss.SSS",
		"yyyy-MM-dd'T'HH:mm:ss.SSSXXX",
		"yyyy-MM-dd'T'HH:mm:ss",
		"yyyy-MM-dd'T'HH:mm",
		"yyyy-MM-dd",
		"dd/mm/yyyy"
	]

	def static Date parses(String dateToFormat) {
		for (format : formats) {
			try {
				var formater = new SimpleDateFormat(format);
				return formater.parse(dateToFormat);
			} catch (Exception e) {
			}
		}
		return null
	}

	def static typeConverted(TypeReference reference, String paramName) {
		switch (reference.simpleName) {
			case "Boolean":
				"Boolean.parseBoolean(" + paramName + ".toString())"
			case "Long":
				"Long.parseLong(" + paramName + ".toString())"
			case "Integer":
				"Integer.parseInt(" + paramName + ".toString())"
			case "String":
				paramName + ".toString()"
			case "Float":
				"Float.parseFloat(" + paramName + ".toString())"
			case "Double":
				"Double.parseDouble(" + paramName + ".toString())"
			case "Date":
				"co.edu.unal.softlibre.Xksoap.utils.Utils.parses(" + paramName + ".toString())"
			case "Character":
				paramName + ".toString().charAt(0)"
			case "byte[]":
				"org.kobjects.base64.Base64.decode(" + paramName + ".toString())"
			default:
				"(" + reference.simpleName + ")" + paramName
		}
	}

}
