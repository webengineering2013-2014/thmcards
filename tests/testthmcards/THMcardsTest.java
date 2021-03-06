package testthmcards;

import org.junit.Test;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.firefox.FirefoxDriver;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

// Author: Roman Domnich ( workaddr [ at ] yahoo.de )

public class THMcardsTest {

	@Test
	public final void mainTest() {

		WebDriver w = new FirefoxDriver();
		
		WebDriverWait wait = new WebDriverWait(w, 20);
		
		w.get("http://localhost:3000");
		
		wait.until(ExpectedConditions.titleContains("THMcards"));
		
	}

}
