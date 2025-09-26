//
//  AuthError.swift
//  Splitza
//
//  Created by Jeffry Sandy Purnomo on 26/09/25.
//

enum AuthError: AppError {
	case anonymousProviderDisabled
	case badCodeVerifier
	case badJson
	case badJwt
	case badOauthCallback
	case badOauthState
	case captchaFailed
	case conflict
	case emailAddressInvalid
	case emailAddressNotAuthorized
	case emailExists
	case emailNotConfirmed
	case emailProviderDisabled
	case flowStateExpired
	case flowStateNotFound
	case hookPayloadInvalidContentType
	case hookPayloadOverSizeLimit
	case hookTimeout
	case hookTimeoutAfterRetry
	case identityAlreadyExists
	case identityNotFound
	case insufficientAal
	case invalidCredentials
	case inviteNotFound
	case manualLinkingDisabled
	case mfaChallengeExpired
	case mfaFactorNameConflict
	case mfaFactorNotFound
	case mfaIpAddressMismatch
	case mfaPhoneEnrollNotEnabled
	case mfaPhoneVerifyNotEnabled
	case mfaTotpEnrollNotEnabled
	case mfaTotpVerifyNotEnabled
	case mfaVerificationFailed
	case mfaVerificationRejected
	case mfaVerifiedFactorExists
	case mfaWebAuthnEnrollNotEnabled
	case mfaWebAuthnVerifyNotEnabled
	case noAuthorization
	case notAdmin
	case oauthProviderNotSupported
	case otpDisabled
	case otpExpired
	case overEmailSendRateLimit
	case overRequestRateLimit
	case overSmsSendRateLimit
	case phoneExists
	case phoneNotConfirmed
	case phoneProviderDisabled
	case providerDisabled
	case providerEmailNeedsVerification
	case reauthenticationNeeded
	case reauthenticationNotValid
	case refreshTokenAlreadyUsed
	case refreshTokenNotFound
	case requestTimeout
	case samePassword
	case samlAssertionNoEmail
	case samlAssertionNoUserId
	case samlEntityIdMismatch
	case samlIdpAlreadyExists
	case samlIdpNotFound
	case samlMetadataFetchFailed
	case samlProviderDisabled
	case samlRelayStateExpired
	case samlRelayStateNotFound
	case sessionExpired
	case sessionNotFound
	case signupDisabled
	case singleIdentityNotDeletable
	case smsSendFailed
	case ssoDomainAlreadyExists
	case ssoProviderNotFound
	case tooManyEnrolledMfaFactors
	case unexpectedAudience
	case unexpectedFailure
	case userAlreadyExists
	case userBanned
	case userNotFound
	case userSsoManaged
	case validationFailed
	case weakPassword
	case unknown(String) // For unmapped errors
	
	case providerError
	
	// MARK: - AppError Protocol Conformance
	
	var userMessage: String {
		switch self {
		case .anonymousProviderDisabled:
			return "Anonymous sign-ins are disabled."
		case .badCodeVerifier:
			return "There was an issue verifying your login. Please try again."
		case .badJson:
			return "Invalid data received. Please try again later."
		case .badJwt:
			return "Your session has expired. Please log in again."
		case .invalidCredentials:
			return "Invalid email or password. Please try again."
		case .emailExists:
			return "This email address is already registered."
		case .emailNotConfirmed:
			return "Please confirm your email address before logging in."
		case .otpExpired:
			return "The OTP code has expired. Please request a new one."
		case .userNotFound:
			return "No account found with this information."
		case .weakPassword:
			return "Your password is too weak. Please use a stronger password."
		default:
			return "An unknown error occurred. Please try again."
		}
	}
	
	var debugMessage: String {
		switch self {
		case .anonymousProviderDisabled:
			return "Anonymous sign-ins are disabled on the server."
		case .badCodeVerifier:
			return "The provided code verifier does not match the expected one."
		case .badJson:
			return "The HTTP body of the request is not valid JSON."
		case .badJwt:
			return "The JWT sent in the Authorization header is not valid."
		case .invalidCredentials:
			return "The login credentials or grant type are not recognized."
		case .providerError:
			return "An error occurred with the authentication provider. Please check provider configurations."
		default:
			return "An unknown error occurred. Debugging required."
		}
	}
	
	var errorCode: String? {
		switch self {
		case .anonymousProviderDisabled: return "anonymous_provider_disabled"
		case .badCodeVerifier: return "bad_code_verifier"
		case .badJson: return "bad_json"
		case .badJwt: return "bad_jwt"
		case .invalidCredentials: return "invalid_credentials"
		default: return nil
		}
	}
}

extension AuthError {
	static func from(errorCode: String) -> AuthError {
		switch errorCode {
		case "anonymous_provider_disabled": return .anonymousProviderDisabled
		case "bad_code_verifier": return .badCodeVerifier
		case "bad_json": return .badJson
		case "bad_jwt": return .badJwt
		case "bad_oauth_callback": return .badOauthCallback
		case "bad_oauth_state": return .badOauthState
		case "captcha_failed": return .captchaFailed
		case "conflict": return .conflict
		case "email_address_invalid": return .emailAddressInvalid
		case "email_address_not_authorized": return .emailAddressNotAuthorized
		case "email_exists": return .emailExists
		case "email_not_confirmed": return .emailNotConfirmed
		case "email_provider_disabled": return .emailProviderDisabled
		case "flow_state_expired": return .flowStateExpired
		case "flow_state_not_found": return .flowStateNotFound
		case "hook_payload_invalid_content_type": return .hookPayloadInvalidContentType
		case "hook_payload_over_size_limit": return .hookPayloadOverSizeLimit
		case "hook_timeout": return .hookTimeout
		case "hook_timeout_after_retry": return .hookTimeoutAfterRetry
		case "identity_already_exists": return .identityAlreadyExists
		case "identity_not_found": return .identityNotFound
		case "insufficient_aal": return .insufficientAal
		case "invalid_credentials": return .invalidCredentials
		case "invite_not_found": return .inviteNotFound
		case "manual_linking_disabled": return .manualLinkingDisabled
		case "mfa_challenge_expired": return .mfaChallengeExpired
		case "mfa_factor_name_conflict": return .mfaFactorNameConflict
		case "mfa_factor_not_found": return .mfaFactorNotFound
		case "mfa_ip_address_mismatch": return .mfaIpAddressMismatch
		case "mfa_phone_enroll_not_enabled": return .mfaPhoneEnrollNotEnabled
		case "mfa_phone_verify_not_enabled": return .mfaPhoneVerifyNotEnabled
		case "mfa_totp_enroll_not_enabled": return .mfaTotpEnrollNotEnabled
		case "mfa_totp_verify_not_enabled": return .mfaTotpVerifyNotEnabled
		case "mfa_verification_failed": return .mfaVerificationFailed
		case "mfa_verification_rejected": return .mfaVerificationRejected
		case "mfa_verified_factor_exists": return .mfaVerifiedFactorExists
		case "mfa_web_authn_enroll_not_enabled": return .mfaWebAuthnEnrollNotEnabled
		case "mfa_web_authn_verify_not_enabled": return .mfaWebAuthnVerifyNotEnabled
		case "no_authorization": return .noAuthorization
		case "not_admin": return .notAdmin
		case "oauth_provider_not_supported": return .oauthProviderNotSupported
		case "otp_disabled": return .otpDisabled
		case "otp_expired": return .otpExpired
		case "over_email_send_rate_limit": return .overEmailSendRateLimit
		case "over_request_rate_limit": return .overRequestRateLimit
		case "over_sms_send_rate_limit": return .overSmsSendRateLimit
		case "phone_exists": return .phoneExists
		case "phone_not_confirmed": return .phoneNotConfirmed
		case "phone_provider_disabled": return .phoneProviderDisabled
		case "provider_disabled": return .providerDisabled
		case "provider_email_needs_verification": return .providerEmailNeedsVerification
		case "reauthentication_needed": return .reauthenticationNeeded
		case "reauthentication_not_valid": return .reauthenticationNotValid
		case "refresh_token_already_used": return .refreshTokenAlreadyUsed
		case "refresh_token_not_found": return .refreshTokenNotFound
		case "request_timeout": return .requestTimeout
		case "same_password": return .samePassword
		case "saml_assertion_no_email": return .samlAssertionNoEmail
		case "saml_assertion_no_user_id": return .samlAssertionNoUserId
		case "saml_entity_id_mismatch": return .samlEntityIdMismatch
		case "saml_idp_already_exists": return .samlIdpAlreadyExists
		case "saml_idp_not_found": return .samlIdpNotFound
		case "saml_metadata_fetch_failed": return .samlMetadataFetchFailed
		case "saml_provider_disabled": return .samlProviderDisabled
		case "saml_relay_state_expired": return .samlRelayStateExpired
		case "saml_relay_state_not_found": return .samlRelayStateNotFound
		case "session_expired": return .sessionExpired
		case "session_not_found": return .sessionNotFound
		case "signup_disabled": return .signupDisabled
		case "single_identity_not_deletable": return .singleIdentityNotDeletable
		case "sms_send_failed": return .smsSendFailed
		case "sso_domain_already_exists": return .ssoDomainAlreadyExists
		case "sso_provider_not_found": return .ssoProviderNotFound
		case "too_many_enrolled_mfa_factors": return .tooManyEnrolledMfaFactors
		case "unexpected_audience": return .unexpectedAudience
		case "unexpected_failure": return .unexpectedFailure
		case "user_already_exists": return .userAlreadyExists
		case "user_banned": return .userBanned
		case "user_not_found": return .userNotFound
		case "user_sso_managed": return .userSsoManaged
		case "validation_failed": return .validationFailed
		case "weak_password": return .weakPassword
		default: return .unknown(errorCode)
		}
	}
}
