package Models

type User struct {
	Id         uint   `json:"id"`
	Name       string `json:"name" validate:"required,min=3,max=20"`
	Email      string `json:"email" gorm:"unique" validate:"required,email"`
	Password   []byte `json:"-"`
	Permission int    `json:"permission" validate:"required,min=0,max=1"`
	// DriverLicenseExpirationDate string `json:"DriverLicenseExpirationDate"`
	// SafetyLicenseExpirationDate string `json:"SafetyLicenseExpirationDate"`
	// DrugTestExpirationDate      string `json:"DrugTestExpirationDate"`
	// MobileNumber                string `json:"mobile_number"`
	// Transporter                 string `gorm:"column:Transporter" json:"Transporter"`
	IsApproved int `gorm:"column:IsApproved" json:"IsApproved"`
	// DriverLicenseImageName      string `gorm:"column:DriverLicenseImageName;default:'';not null" json:"DriverLicenseImageName"`
	// SafetyLicenseImageName      string `gorm:"column:SafetyLicenseImageName;default:'';not null" json:"SafetyLicenseImageName"`
	// DrugTestImageName           string `gorm:"column:DrugTestImageName;default:'';not null" json:"DrugTestImageName"`
	// DriverLicenseImageNameBack  string `gorm:"column:DriverLicenseImageNameBack;default:'';not null" json:"DriverLicenseImageNameBack"`
	// SafetyLicenseImageNameBack  string `gorm:"column:SafetyLicenseImageNameBack;default:'';not null" json:"SafetyLicenseImageNameBack"`
	// DrugTestImageNameBack       string `gorm:"column:DrugTestImageNameBack;default:'';not null" json:"DrugTestImageNameBack"`
}
