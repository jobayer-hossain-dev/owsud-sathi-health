/**
 * Standard API response format
 */
function successResponse(res, data, message = 'Success', statusCode = 200) {
  return res.status(statusCode).json({
    success: true,
    message,
    data,
  });
}

function errorResponse(res, message = 'Something went wrong', statusCode = 500, errors = null) {
  const response = {
    success: false,
    message,
  };
  if (errors) response.errors = errors;
  return res.status(statusCode).json(response);
}

function paginatedResponse(res, data, total, page, limit, message = 'Success') {
  return res.status(200).json({
    success: true,
    message,
    data,
    pagination: {
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    },
  });
}

/**
 * Format MySQL datetime for Bangladesh timezone (UTC+6)
 */
function formatBDTime(date) {
  return new Date(date).toLocaleString('bn-BD', { timeZone: 'Asia/Dhaka' });
}

module.exports = { successResponse, errorResponse, paginatedResponse, formatBDTime };
