package Models

type User struct {
	Id                          uint   `json:"id"`
	Name                        string `json:"name" validate:"required,min=3,max=20"`
	Email                       string `json:"email" gorm:"unique" validate:"required,email"`
	Password                    []byte `json:"-"`
	Permission                  int    `json:"permission" validate:"required,min=0,max=1"`
	DriverLicenseExpirationDate string `json:"DriverLicenseExpirationDate"`
	SafetyLicenseExpirationDate string `json:"SafetyLicenseExpirationDate"`
	DrugTestExpirationDate      string `json:"DrugTestExpirationDate"`
	MobileNumber                string `json:"mobile_number"`
	IsApproved                  int    `gorm:"column:IsApproved" json:"IsApproved"`
}
