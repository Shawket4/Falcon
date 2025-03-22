package Controllers

import (
	"fmt"
	"regexp"
	"strings"
)

func ParseTransactionMessage(message string) []string {
	keywords := []string{"خصم", "رقم", "عند", "يوم", "الساعة", "الساعه", "المتاح"}
	regexPattern := fmt.Sprintf(`(?:%s)\s+(\S+)`, strings.Join(keywords, "|"))

	re := regexp.MustCompile(regexPattern)
	matches := re.FindAllStringSubmatch(message, -1)

	var extractedWords []string

	for _, match := range matches {
		if len(match) > 1 {
			extractedWords = append(extractedWords, match[1])
		}
	}
	return extractedWords
}

func ParseTransactionMessagePlace(message string) []string {
	regexPattern := `عند\s+(.*?)\s+يوم`

	re := regexp.MustCompile(regexPattern)
	matches := re.FindAllStringSubmatch(message, -1)

	var extractedPhrases []string

	for _, match := range matches {
		if len(match) > 1 {
			extractedPhrases = append(extractedPhrases, match[1])
		}
	}

	return extractedPhrases
}

func ParseInstapayMessage(message string, bank string) []string {
	if bank == "Al Ahly" {
		keywords := []string{"المنتهية بـ", "يوم", "الساعة", "بمبلغ"}
		var extractedPhrases []string

		for _, keyword := range keywords {
			if strings.Contains(message, keyword) {
				parts := strings.SplitAfter(message, keyword)
				if len(parts) >= 2 {
					phrase := strings.TrimSpace(parts[1])
					if spaceIndex := strings.Index(phrase, " "); spaceIndex != -1 {
						extractedPhrases = append(extractedPhrases, phrase[:spaceIndex])
					} else {
						extractedPhrases = append(extractedPhrases, phrase)
					}
				}
			}
		}
		for index := range extractedPhrases {
			extractedPhrases[index] = strings.Replace(extractedPhrases[index], "الساعة", "", -1)
		}

		return extractedPhrases
	} else if bank == "AAIB" {
		keywords := []string{"value of", "on"}
		var extractedPhrases []string
		for _, keyword := range keywords {
			if strings.Contains(message, keyword) {
				parts := strings.SplitAfter(message, keyword)
				if len(parts) >= 2 {
					phrase := strings.TrimSpace(parts[1])
					if spaceIndex := strings.Index(phrase, " "); spaceIndex != -1 {
						extractedPhrases = append(extractedPhrases, phrase[:spaceIndex])
					} else {
						extractedPhrases = append(extractedPhrases, phrase)
					}
				}
			}
		}

		return extractedPhrases
	}
	return nil
}
