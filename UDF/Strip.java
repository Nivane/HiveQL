package thisisnobody.udf;

import org.apache.commons.lang3.StringUtils;
import org.apache.hadoop.hive.ql.exec.UDF;
import org.apache.hadoop.io.Text;

public class Strip extends UDF {

	private Text result = new Text();

	//去除空白字符
	public Text evaluate(Text str) {
		if (str == null) {
			return null;
		}
		result.set(StringUtils.strip(str.toString()));
		return result;

	}
	
	//字符串的头和尾不能有stripChars中的字符
	// ('banana', 'ab') => nan
	// ('ababababa', 'ab') => null
	public Text evaluate(Text str, String stripChars) {
		if (str == null) {
			return null;
		}

		result.set(StringUtils.strip(str.toString(), stripChars));
		return result;

	}
}
